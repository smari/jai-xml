

Parser :: struct(Status: Type) {
    input           : string;
    remaining       : string;
    status          : Status;
    error_message   : string;
    error_context   : string;
}


parse_error :: (p: *$T/Parser, error: T.Status, message: string = "", loc := #caller_location) {
    p.status = error;
    if message { p.error_message = message; }
    p.error_context = slice(p.remaining, 0, 10);
    //prelude := p.input;
    //prelude.count = p.input.count - p.remaining.count;

    //line, char := get_line_and_char(prelude);

    // log("Parse error: % at %:%: %. Next bytes are: '%'", error, line, char, ifx message then message else "No detail given", slice(p.remaining, 0, 10));
}

parse_get_location :: (p: *$T/Parser) -> line: int, char: int {
    prelude := p.input;
    prelude.count = p.input.count - p.remaining.count;

    line, char := get_line_and_char(prelude);
    return line, char;    
}

parse_print_status :: (p: *$T/Parser) {
    prelude := p.input;
    prelude.count = p.input.count - p.remaining.count;
    line, char := get_line_and_char(prelude);
    log("Parser status:%:%: bytes are: '%'", line, char, slice(p.remaining, 0, 10));   
}

lexer_peek :: inline (p: *$T/Parser, ch: u8) -> bool #expand {
    if p.remaining.count == 0 || p.remaining[0] != ch return false;
    return true;
}

lexer_peek :: inline (p: *$T/Parser, str: string) -> bool {
    if p.remaining.count <= str.count {
        // early out if we'll never make it.
        return false;
    }
    for 0..str.count-1 {
        if p.remaining[it] != str[it] {
            return false;
        }
    }
    return true;
}

lexer_accept :: inline (p: *$T/Parser, str: string, fail_if_not_found: bool = false, error_message: string = "") {
    if lexer_peek(p, str) {
        lexer_advance(p, str.count);
    } else if fail_if_not_found {
        parse_error(p, .syntax_error, error_message);
    }
}

lexer_accept_name :: inline (p: *$T/Parser) -> string {
    mark := p.remaining;
    mark.count = 0;
    while p.remaining.count > 0 && xml_is_namechar(p.remaining[0]) {
        code, bytes, success := character_utf8_to_utf32(p.remaining.data, p.remaining.count);
        mark.count += bytes;
        lexer_advance(p, bytes);
    }
    return mark;   
}

lexer_accept_padded :: inline (p: *$T/Parser, str: string, fail_if_not_found: bool = false) -> bool {
    lexer_skip_whitespace(p);
    if lexer_peek(p, str) {
        lexer_advance(p, str.count);
        lexer_skip_whitespace(p);
        return true;
    }
    if fail_if_not_found then parse_error(p, .syntax_error, "Expected string but didn't find it.");
    return false;
}

lexer_accept_until :: inline (p: *$T/Parser, chr: u8) -> string {
    mark := p.remaining;
    mark.count = 0;
    while p.remaining.count > 0 && p.remaining[0] != chr {
        mark.count += 1;
        lexer_advance(p);
    }
    return mark;
}

find_substring_sse3 :: (haystack: string, needle: string) -> index: int, found: bool {
    /*
     * This is based on code from the jai-strings library
     * by Iain King (onelivesleft)
     * https://github.com/onelivesleft/jai-string/
     */

    if needle.count == 0  return 0, true;
    if needle.count == 1 {
        index := find_index_from_left(haystack, <<needle.data);
        return index, index >= 0;
    }
    if haystack.count - needle.count < 0 return -1, false;

    end := cast(u64)haystack.data + cast(u64)(haystack.count - needle.count);
    needle_end := cast(u64)needle.count - 1;
    haystack_ptr := cast(u64)haystack.data;

    end_simd := end - 15;
    if haystack_ptr < end_simd {
        needle_buffer : [16] u8;
        needle_ptr := *needle_buffer;
        memset(needle_ptr, <<needle.data, 16);

        results : struct { index, found : u16; };
        results_data := *results;

        #asm {
            movdqu.x   needle_vec:, [needle_ptr];
        }

        while haystack_ptr < end_simd {
            #asm {
                movdqu.x   results_vec:, [haystack_ptr];

                /* check for equality */
                pcmpeqb.x  results_vec, needle_vec;
                pmovmskb.x found_gpr:, results_vec;

                /* calculate index of first equal character */
                tzcnt.w    index_gpr:, found_gpr;

                /* pack found:index and export */
                shl.d      found_gpr, 16;
                or.w       found_gpr, index_gpr;
                mov.d      [results_data], found_gpr;
            }

            if results.found {
                word_index := haystack_ptr + results.index;
                second_character_index := word_index + 1;
                needle_index := needle.data + 1;
                for character: second_character_index .. word_index + needle_end {
                    if <<cast(*u8)character != <<needle_index {
                        haystack_ptr = second_character_index;
                        break;
                    }
                    needle_index += 1;
                }
                if haystack_ptr < second_character_index {
                    return cast(int)(word_index - cast(u64)haystack.data), true;
                }
            }
            else
                haystack_ptr += 16;
        }
    }

    for index: haystack_ptr .. end {
        needle_index := needle.data;
        for character: index .. index + needle_end {
            if <<cast(*u8)character != <<needle_index
                continue index;
            needle_index += 1;
        }
        return cast(int)(index - cast(u64)haystack.data), true;
    }

    return -1, false;
}


find_substring :: inline (haystack: string, needle: string) -> bool, int {
    #if USE_SIMD_STRING_SEARCH {
        index, found := find_substring_sse3(haystack, needle);
    } else {
        index := find_index_from_left(haystack, needle);
        found := index >= 0;
    }
    return found, index;        
}


lexer_accept_until :: inline (p: *$T/Parser, str: string) -> string, bool {
    mark := p.remaining;
    // TODO: This is slow:
    found, index := find_substring(p.remaining, str);
    if found {
        mark.count = index;
        lexer_advance(p, mark.count);
    }
    return mark, found;
}

lexer_accept_quoted_string :: inline (p: *$T/Parser) -> string {
    quote_mark : u8;
    if p.remaining[0] == #char "\"" || p.remaining[0] == #char "'" {
        quote_mark = p.remaining[0];
        lexer_advance(p);
        str := lexer_accept_until(p, quote_mark);
        lexer_advance(p);
        return str;
    }
    return "";
}

lexer_advance :: inline (p: *$T/Parser, amount: int = 1) {
    assert(amount >= 0);
    if (p.remaining.count < amount) return;
    p.remaining.count -= amount;
    p.remaining.data  += amount;
}

lexer_skip_whitespace :: inline (p: *$T/Parser, $$must: bool = false) {
    skipped := 0;
    while true {
        if p.remaining.count == 0 break;
        if p.remaining[0] == {
            case #char " ";  #through;
            case #char "\r"; #through;
            case #char "\t"; #through;
            case #char "\n"; {
                skipped += 1;
                lexer_advance(p);
            }
            case; break;
        }
    }
    #if must {
        if skipped == 0 { parse_error(p, .missing_whitespace); }
    }
}

#scope_file

get_line_and_char :: (s: string) -> int, int {
    line := 1;
    char := 0;
    for 0..s.count-1 {
        if s[it] == #char "\n" {
            line += 1;
            char = 0;
        } else {
            char += 1;
        }
    }
    return line, char;
}
