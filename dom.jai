// DOM functionality

XMLDocument :: struct {
    root       : *XMLNode;
    version    : string;
    encoding   : XMLEncoding;
    standalone : bool;
}

XMLNodeType :: enum {
    empty;       // Empty node handle
    document;    // A document tree's absolute root
    element;     // Element tag, i.e. '<node/>'
    pcdata;      // Plain character data, i.e. 'text'
    cdata;       // Character data, i.e. '<![CDATA[text]]>'
    comment;     // Comment tag, i.e. '<!-- text -->'
    pi;          // Processing instruction, i.e. '<?name?>'
    declaration; // Document declaration, i.e. '<?xml version="1.0"?>'
    doctype;     // Document type declaration, i.e. '<!DOCTYPE doc>'
}

XMLEncoding :: enum {
    auto;
    utf8;
    utf16_le;
    utf16_be;
    utf16;
    utf32_le;
    utf32_be;
    utf32;
    wchar;
    latin1;
}

XMLAttribute :: struct {
    name            : string;
    value           : string;
}

XMLNodeFlags :: enum_flags {
    Empty;  // <.../> - no children.
}


XMLNode :: struct {
    type            : XMLNodeType;
    name            : string;
    value           : string;

    parent          : *XMLNode;
    first_child     : *XMLNode;
    prev_sibling    : *XMLNode;
    next_sibling    : *XMLNode;

    attributes      : [..]*XMLAttribute;
    flags           : XMLNodeFlags;
}


attribute_allocate :: inline () -> *XMLAttribute {
    return New(XMLAttribute);
}

attribute_free :: (attrib: *XMLAttribute) {
    if !attrib return;
    if attrib.name   free(attrib.name);
    if attrib.value  free(attrib.value);
    free(attrib);
}

attribute_get :: (node: *XMLNode, name: string) -> *XMLAttribute {
    for node.attributes {
        if it.name == name then return it;
    }
    return null;
}

attribute_get_value :: (node: *XMLNode, name: string, default := "") -> string, bool {
    attr := attribute_get(node, name);
    if attr {
        return attr.value, true;
    }
    return default, false;
}

node_allocate :: inline () -> *XMLNode {
    return New(XMLNode);   
}

node_create :: (type: XMLNodeType) -> *XMLNode {
    node := node_allocate();
    node.type = type;
    return node;
}

node_free :: (node: *XMLNode) {
    for node {
        if !node { continue; }
        if node.name   free(node.name);
        if node.value  free(node.value);

        for node.attributes {
            attribute_free(it);
        }
        free(node);
    }
}


node_append :: (child: *XMLNode, node: *XMLNode) {
    child.parent = node;
    if node.first_child == null {
        node.first_child = child;
    } else {
        last := node.first_child;
        while true {
            if last.next_sibling == null {
                child.prev_sibling = last;
                last.next_sibling = child;
                break;
            } else {
                last = last.next_sibling;
            }
        }
    }
}

node_prepend :: (child: *XMLNode, node: *XMLNode) {
    child.parent = node;
    if node.first_child != null {
        node.first_child.prev_sibling = child;
    }
    child.next_sibling = node.first_child;
    node.first_child = child;
}

node_insert_after :: (sibling: *XMLNode, node: *XMLNode) {
    sibling.parent = node.parent;
    sibling.prev_sibling = node;
    sibling.next_sibling = node.next_sibling;
    if node.next_sibling {
        node.next_sibling.prev_sibling = sibling;
    }
    node.next_sibling = sibling;
}

node_insert_before :: (sibling: *XMLNode, node: *XMLNode) {
    sibling.parent = node.parent;
    if node.prev_sibling {
        node.prev_sibling.next_sibling = sibling;
    }
    sibling.prev_sibling = node.prev_sibling;
    sibling.next_sibling = node;
    node.prev_sibling = sibling;
}

node_remove :: (node: *XMLNode) {
    prev := node.prev_sibling;
    next := node.next_sibling;
    if node.prev_sibling {
        node.prev_sibling.next_sibling = node.next_sibling;
    }
    if node.next_sibling {
        node.next_sibling.prev_sibling = prev;
    }
    if node.parent.first_child == node {
        node.parent.first_child = next;
    }
}


node_find_child_by_tag :: (node: *XMLNode, tag: string, from: *XMLNode = null) -> *XMLNode {
    // Returns first child node with the name tag, starting from node 'from' if one is given, else
    // starting from the first child.
    // Note: This only looks at immediate children, and not at deeper descendants.
    cursor : *XMLNode;
    if from == null {
        cursor = node.first_child;
    } else {
        cursor = from.next_sibling;
        if from.parent != node {
            log("node_find_child_by_tag: 'from' node is not a child of 'node'");
            return null;
        }
    }
    while true {
        if cursor == null return null;
        if cursor.name == tag return cursor;
        cursor = cursor.next_sibling;
    }
    return null;
}

node_get_cdata :: (node: *XMLNode) -> string, bool {
    // TODO: What happens if there are multiple CDATA?
    // For now we return the first.
    if node == null return "", false;
    cursor := node.first_child;
    while true {
        if cursor == null return "", false;
        if cursor.type == .cdata return cursor.value, true;
        cursor = cursor.next_sibling;
    }
    return "", false;
}

attribute_append :: (attr: *XMLAttribute, node: *XMLNode) {
    array_add(*node.attributes, attr);
}

attribute_append :: (node: *XMLNode, key: string, value: string) {
    attr := attribute_allocate();
    attr.name = copy_string(key);
    attr.value = copy_string(value);
    array_add(*node.attributes, attr);
}

attribute_prepend :: (attr: *XMLAttribute, node: *XMLNode) {
    log("UNIMPLEMENTED attribute_prepend");
}

attribute_insert_after :: (attr: *XMLAttribute, node: *XMLNode) {
    log("UNIMPLEMENTED attribute_insert_after");    
}

attribute_insert_before :: (attr: *XMLAttribute, node: *XMLNode) {
    log("UNIMPLEMENTED attribute_insert_before");
}

attribute_remove :: (attr: *XMLAttribute, node: *XMLNode) {
    log("UNIMPLEMENTED attribute_remove");    
}

node_append_new :: (node: *XMLNode, type: XMLNodeType) -> *XMLNode {
    child := node_create(type);
    if !child return null;
    node_append(child, node);
    return child;
}

attribute_append_new :: (node: *XMLNode) -> *XMLAttribute {
    attr := New(XMLAttribute);
    if !attr return null;
    attribute_append(attr, node);
    return attr;
}


XMLNodeWalkCallback :: #type (node: *XMLNode);

xml_walk_depthfirst :: (node: *XMLNode, callback: XMLNodeWalkCallback) {
    if node == null return;
    callback(node);
    xml_walk_depthfirst(node.first_child, callback);
    xml_walk_depthfirst(node.next_sibling, callback);
}

xml_walk_breadthfirst :: (node: *XMLNode, callback: XMLNodeWalkCallback) {
    if node == null return;
    callback(node);
    xml_walk_breadthfirst(node.next_sibling, callback);
    xml_walk_breadthfirst(node.first_child, callback);
}

for_expansion :: (node: *XMLNode, body: Code, flags: For_Flags) #expand {
    #assert(flags == 0); // No flags supported yet.

    `it_index := 0;
    cursor := node;

    while outer := true {
        `it := cursor;

        #insert body;

        `it_index += 1;

        if cursor.first_child != null { 
            cursor = cursor.first_child;
            continue;
        } else if cursor.next_sibling != null {
            cursor = cursor.next_sibling;
            continue;
        }

        while cursor.parent != null {
            if cursor.parent == node {
                // Break early if we're ascending above our starting point.
                break outer;
            } else if cursor.parent.next_sibling != null {
                cursor = cursor.parent.next_sibling;
                continue outer;
            } else {
                cursor = cursor.parent;
            }
        }
        break;
    }

}
