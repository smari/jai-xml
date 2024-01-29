

XMLParseResult :: struct {
    status    : XMLParseStatus;
    encoding  : XMLEncoding;
    remaining : string;
    error_message : string;
    line      : int;
    char      : int;
}


XMLParseStatus :: enum {
    ok :: 0;              // No error
    file_not_found;       // File was not found during load_file()
    io_error;             // Error reading from file/stream
    out_of_memory;        // Could not allocate memory
    internal_error;       // Internal error occurred
    unrecognized_tag;     // p could not determine tag type
    invalid_encoding;     // An encoding we don't support

    bad_pi;               // Parsing error occurred while parsing document declaration/processing instruction
    bad_comment;          // Parsing error occurred while parsing comment
    bad_cdata;            // Parsing error occurred while parsing CDATA section
    bad_doctype;          // Parsing error occurred while parsing document type declaration
    bad_pcdata;           // Parsing error occurred while parsing PCDATA section
    bad_start_element;    // Parsing error occurred while parsing start element tag
    bad_attribute;        // Parsing error occurred while parsing element attribute
    bad_end_element;      // Parsing error occurred while parsing end element tag
    end_element_mismatch; // There was a mismatch of start-end tags (closing tag had incorrect name, some tag was not closed or there was an excessive closing tag)
    missing_whitespace;   // Mandatory whitespace was missing.
    syntax_error;

    append_invalid_root;  // Unable to append nodes since root type is not node_element or node_document (exclusive to xml_node::append_buffer)
    no_document_element;  // Parsing resulted in a document without element nodes
    preexisting_root;     // Starting a parse with root node prepopulated.
}

XMLParser :: struct {
    #as using base_parser : Parser(XMLParseStatus);
    using document    : XMLDocument;
    cursor      : *XMLNode;
}

xml_parse :: (buffer: string) -> *XMLNode, XMLParseResult {
    p : XMLParser;
    p.input = buffer;
    p.remaining = buffer;

    parse_tree(*p);
    res : XMLParseResult;
    res.status = p.status;
    res.remaining = p.remaining;
    res.encoding = p.encoding;
    res.error_message = p.error_message;
    res.line, res.char = parse_get_location(*p);
    return p.root, res;
}   

xml_parse_file :: (file: string) -> *XMLNode, XMLParseResult {
    // TODO: Optimize this a bit.
    buf, success := read_entire_file(file);    
    if !success {
        pr : XMLParseResult;
        pr.status = .file_not_found;
        return null, pr;
    }
    root, res := xml_parse(buf);
    free(buf);
    return root, res;
}


xml_free :: (node: *XMLNode) {
    node_free(node);
}


#scope_file


node_push :: (type: XMLNodeType) #expand {
    `cursor = node_append_new(`cursor, type);
    if (!`cursor) parse_error(`p, .out_of_memory);
}

node_pop :: () #expand {
    `cursor = `cursor.parent;
}


parse_tree :: (using p: *XMLParser) {
    if p.root {
        parse_error(p, .preexisting_root);
        return;
    }
    mark : string;
    root = node_create(.document);
    cursor = root;

    parse_detect_encoding(p);
    if p.encoding != .utf8 {
        parse_error(p, .invalid_encoding, tprint("Currently encoding % is unsupported", p.encoding));
        return;
    }
    parse_prolog(p);

    while remaining.count != 0 {
        lexer_skip_whitespace(p);

        if remaining.count == 0 break;

        if lexer_peek(p, "<!") {
                // <!...
            if starts_with(remaining, "<!--") {
                lexer_advance(p, 4);
                s, found := lexer_accept_until(p, "-->");
                if !found {
                    parse_error(p, .bad_comment);
                    return;
                }
                comment := node_create(.comment);
                comment.value = copy_string(s);
                node_append(comment, cursor);
                lexer_advance(p, 3);
            } else if starts_with(remaining, "<![CDATA[") {
                // TODO: This is very slow.
                // CDATA!
                lexer_advance(p, 9);
                s, found := lexer_accept_until(p, "]]>");
                if !found {
                    parse_error(p, .bad_cdata);
                    return;
                }
                cdata := node_create(.cdata);
                cdata.value = copy_string(s);
                node_append(cdata, cursor);
                lexer_advance(p, 3);
            } else if starts_with(remaining, "<!ELEMENT") {
                s, found := lexer_accept_until(p, ">");
                lexer_advance(p);
            } else if starts_with(remaining, "<!ENTITY") {
                s, found := lexer_accept_until(p, ">");
                lexer_advance(p);
            } else if starts_with(remaining, "<!DOCTYPE") {
                parse_doctype(p);
            } else {
                // Nothing else is legal.
                parse_error(p, .bad_start_element, "Unable to parse after <!");
                return;
            }
        } else if lexer_peek(p, "<?") {
            // <?...
            // This is a processing instruction
            lexer_advance(p, 2);
            s, found:= lexer_accept_until(p, "?>");
            if !found {
                parse_error(p, .bad_pi);
                return;
            }
            lexer_advance(p, 2);
            pi := node_create(.pi);
            pi.value = copy_string(s);
            node_append(pi, cursor);

        } else if lexer_peek(p, "</") {
            // </...
            lexer_advance(p, 2);
            lexer_skip_whitespace(p);

            name := lexer_accept_name(p);

            lexer_skip_whitespace(p);

            if remaining.count == 0 {
                parse_error(p, .bad_end_element, "Expected closing '>' but found end of file\n");
                return;
            }

            if remaining[0] != #char ">" {
                parse_error(p, .bad_end_element, "Expected closing '>' but found something else\n");
                return;
            }
            lexer_advance(p);
            if name != cursor.name {
                parse_error(p, .bad_end_element, tprint("Expected closing of '%' but found '%'", cursor.name, name));
                return;
            }
            node_pop();
            continue;

        } else if remaining[0] == #char "<" {
            // other "<" -- probably a tag!
            lexer_advance(p);
            name := lexer_accept_name(p);
            node_push(.element);
            cursor.name = copy_string(name);
            parse_attributes(p);
            if p.status != .ok break;
            continue;
        } else {
            if remaining.count == 0 break;

            if cursor.type == .document {
                parse_error(p, .no_document_element, "Doesn't seem to be an XML file?");
                return;
            }
            {
                node_push(.pcdata);
                cursor.value = lexer_accept_until(p, #char "<");
                node_pop();
            }
            continue;
        }
    }

    return;
}


parse_detect_encoding :: (using p: *XMLParser) {
    // If encoding is preset, we do nothing here. (TODO: Is that smart?)
    if p.encoding != .auto { return; }

    // Assume utf8 as default, then override if we find evidence to the contrary.
    p.encoding = .utf8; 

    if starts_with(remaining, "\xEF\xBB\xBF") {
        // Here we skip the Byte Order Mark if present.
        lexer_advance(p, 3);
        // This is a strong indicator we've got utf-8
        p.encoding = .utf8;
    } else if starts_with(remaining, "\xFE\xFF") {
        p.encoding = .utf16;
        lexer_advance(p, 2);
    }
}


parse_attributes :: inline (using p: *XMLParser) {
    // We've got other stuff in the tag.
    while true {
        lexer_skip_whitespace(p);

        if remaining.count == 0 break;

        if (remaining[0] == #char ">") {
            lexer_advance(p);
            break;
        } else if xml_is_namechar(remaining) {
            found, key, value := parse_attribute(p);
            if !found {
                log("This shouldn't be possible?");
                break;
            }
            attr := attribute_append_new(cursor);
            attr.name = copy_string(key);
            attr.value = copy_string(value);

        } else if (remaining[0] == #char "/") {
            lexer_advance(p);
            if (remaining[0] == #char ">") {
                lexer_advance(p);
                cursor.flags |= .Empty;
                node_pop();              
                break;
            } else {
                parse_error(p, .bad_start_element, "Expecting closing > after / in empty element");
                return;
            }
        } else {
            parse_error(p, .bad_start_element, "Found something strange in attributes.");
            break;
        }
    }
}


parse_prolog :: inline (using p: *XMLParser) #expand {
    // Prolog is XMLDecl? Misc* (doctypedecl Misc*)?
    if remaining.count > 5 && starts_with(remaining, "<?xml") {
        lexer_advance(p, 5);
        lexer_skip_whitespace(p, must=true);

        node_push(.declaration);

        versionfound := false;
        while true {
            found, key, value := parse_attribute(p);
            if !found break;
            if key == {
                case "version"; 
                    versionfound = true;
                    p.document.version = value;
                    attribute_append(cursor, key, value);
                case "encoding";
                    // TODO: handle other encodings.
                    p.document.encoding = .utf8;
                    attribute_append(cursor, key, value);
                case "standalone";
                    p.document.standalone = true;
                    attribute_append(cursor, key, value);
                case;
                    parse_error(p, .bad_attribute);
            }
            lexer_skip_whitespace(p);
        }

        lexer_skip_whitespace(p);
        lexer_accept(p, "?>", fail_if_not_found=true, error_message="Expecting closing ?> but didn't find it.");
        node_pop();
        if !versionfound then parse_error(p, .bad_doctype);

    }
}

parse_doctype :: inline (using p: *XMLParser) {
    // We know "<!DOCTYPE" is there. So skip it.
    lexer_advance(p, 9);
    lexer_skip_whitespace(p, must=true);
    name := lexer_accept_name(p);

    lexer_skip_whitespace(p);

    if starts_with(remaining, "SYSTEM") {
        lexer_advance(p, 6);
        lexer_skip_whitespace(p);        
        systemliteral := lexer_accept_quoted_string(p);
    } else if starts_with(remaining, "PUBLIC") {
        pubid := lexer_accept_quoted_string(p);
        lexer_skip_whitespace(p);
        systemliteral := lexer_accept_quoted_string(p);
    }

    lexer_skip_whitespace(p);
    if starts_with(remaining, "[") {
        // TODO: Do this the right way.
        lexer_accept_until(p, #char "]");
        lexer_advance(p);
/*
    TODO: Handle !DOCTYPE correctly.
        while true {
            if lexer_peek(p, #char "%") {
                // PEreference.
                // TODO: Do we want to do anything with this?
                lexer_advance(p);
                s := lexer_accept_name(p);
                lexer_accept(p, ";");
            } else if lexer_peek(p, "<!") {
                abs := lexer_accept_until(p, #char ">");
                lexer_advance(p);
            } else if lexer_peek(p, "<?") {
                lexer_accept_until(p, #char ">");
                lexer_advance(p);
            } else if lexer_peek(p, #char "]") {
                lexer_advance(p);
                break;
            } else {
                parse_error(p, .bad_doctype, "Unhandled DOCTYPE handle");
                break;
            }
            print("Next: '%'\n", slice(p.remaining, 0, 10));
            lexer_skip_whitespace(p);
        }
*/
    }

    lexer_skip_whitespace(p);
    // TODO: Do this the right way.
    lexer_accept(p, ">", true, "Expected closing '>'");

}

parse_attribute :: inline (using p: *XMLParser) -> bool, string, string {
    key := lexer_accept_name(p);
    if !key return false, "", "";

    value : string;
    if lexer_accept_padded(p, "=") {
        value = lexer_accept_quoted_string(p);
    }
    return true, key, value;
}

#scope_export

xml_write :: (node: *XMLNode) -> string {
    s : String_Builder;

    write_attributes :: (node: *XMLNode, s: *String_Builder) {
        for node.attributes {
            append(s, tprint(" %", it.name));
            if it.value {
                append(s, tprint("=\"%\"", it.value));
            }
        }
    }

    write_node :: (node: *XMLNode, s: *String_Builder, indent := 0) {
        if !node return;
        if node.type == {
            case .element;
                for 0..indent append(s, "  ");
                append(s, tprint("<%", node.name));
                write_attributes(node, s);
                if node.flags & .Empty {
                    append(s, tprint("/>\n"));
                } else {
                    append(s, tprint(">\n"));
                    write_node(node.first_child, s, indent+1);
                    for 0..indent append(s, "  ");
                    append(s, tprint("</%>\n", node.name));
                }
                write_node(node.next_sibling, s, indent);

            case .cdata; {
                append(s, "<![CDATA[");
                append(s, node.value);
                append(s, "]]>");
                write_node(node.next_sibling, s, indent);
            }
            case .pcdata; {
                for 0..indent append(s, "  ");
                append(s, node.value);
                append(s, "\n");
                write_node(node.next_sibling, s, indent);
            }
            case .comment; {
                // Comment tag, i.e. '<!-- text -->'
                append(s, "<!-- ");
                append(s, node.value);
                append(s, " -->");
                write_node(node.next_sibling, s, indent);
            }
            case .pi; {
                // Processing instruction, i.e. '<?name?>'
            }
            case .declaration; {
                // Document declaration, i.e. '<?xml version="1.0"?>'
                append(s, "<?xml ");
                write_attributes(node, s);
                append(s, "?>\n");
                write_node(node.next_sibling, s, indent);
            }
            case .doctype; {
                // Document type declaration, i.e. '<!DOCTYPE doc>'
            }
            case .document; {
                // Write preamble?
                write_node(node.first_child, s, 0);
            }
        }
    }

    write_node(node, *s);
    return builder_to_string(*s);
}

#scope_file 

#load "settings.jai";
#load "parsing.jai";
#load "unicode.jai";
#load "dom.jai";

#import "String";
#import "File";
#import "Basic";
#import "Unicode";
