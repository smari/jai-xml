
xml_is_digit :: (s: string) -> bool {
    cp, bytes, success := character_utf8_to_utf32(s.data, s.count);
    if success != .CONVERSION_OK return false;
    return xml_is_digit(cp);
}

xml_is_digit :: (cp: u32) -> bool {
    if (cp >= 0x0030 && cp <= 0x0039)
    || (cp >= 0x0660 && cp <= 0x0669)
    || (cp >= 0x06F0 && cp <= 0x06F9)
    || (cp >= 0x0966 && cp <= 0x096F)
    || (cp >= 0x09E6 && cp <= 0x09EF)
    || (cp >= 0x0A66 && cp <= 0x0A6F) 
    || (cp >= 0x0AE6 && cp <= 0x0AEF)
    || (cp >= 0x0B66 && cp <= 0x0B6F)
    || (cp >= 0x0BE7 && cp <= 0x0BEF) 
    || (cp >= 0x0C66 && cp <= 0x0C6F)
    || (cp >= 0x0CE6 && cp <= 0x0CEF)
    || (cp >= 0x0D66 && cp <= 0x0D6F) 
    || (cp >= 0x0E50 && cp <= 0x0E59)
    || (cp >= 0x0ED0 && cp <= 0x0ED9)
    || (cp >= 0x0F20 && cp <= 0x0F29)
    then return true;
    return false;
}


xml_is_basechar :: (s: string) -> bool {
    cp, bytes, success := character_utf8_to_utf32(s.data, s.count);
    if success != .CONVERSION_OK return false;
    return xml_is_basechar(cp);
}

xml_is_basechar :: (cp: u32) -> bool {
    if (cp >= 0x0041 && cp <= 0x005A) return true;
    if (cp >= 0x0061 && cp <= 0x007A) return true;
    if (cp >= 0x00C0 && cp <= 0x00D6) return true;
    if (cp >= 0x00D8 && cp <= 0x00F6) return true;
    if (cp >= 0x00F8 && cp <= 0x00FF) return true;
    if (cp >= 0x0100 && cp <= 0x0131) return true;
    if (cp >= 0x0134 && cp <= 0x013E) return true;
    if (cp >= 0x0141 && cp <= 0x0148) return true;
    if (cp >= 0x014A && cp <= 0x017E) return true;
    if (cp >= 0x0180 && cp <= 0x01C3) return true;
    if (cp >= 0x01CD && cp <= 0x01F0) return true;
    if (cp >= 0x01F4 && cp <= 0x01F5) return true;
    if (cp >= 0x01FA && cp <= 0x0217) return true;
    if (cp >= 0x0250 && cp <= 0x02A8) return true;
    if (cp >= 0x02BB && cp <= 0x02C1) return true;
    if (cp >= 0x0388 && cp <= 0x038A) return true;
    if (cp >= 0x038E && cp <= 0x03A1) return true;
    if (cp >= 0x03A3 && cp <= 0x03CE) return true;
    if (cp >= 0x03D0 && cp <= 0x03D6) return true;
    if (cp >= 0x03E2 && cp <= 0x03F3) return true;
    if (cp >= 0x0401 && cp <= 0x040C) return true;
    if (cp >= 0x040E && cp <= 0x044F) return true;
    if (cp >= 0x0451 && cp <= 0x045C) return true;
    if (cp >= 0x045E && cp <= 0x0481) return true;
    if (cp >= 0x0490 && cp <= 0x04C4) return true;
    if (cp >= 0x04C7 && cp <= 0x04C8) return true;
    if (cp >= 0x04CB && cp <= 0x04CC) return true;
    if (cp >= 0x04D0 && cp <= 0x04EB) return true;
    if (cp >= 0x04EE && cp <= 0x04F5) return true;
    if (cp >= 0x04F8 && cp <= 0x04F9) return true;
    if (cp >= 0x0531 && cp <= 0x0556) return true;
    if (cp >= 0x0561 && cp <= 0x0586) return true;
    if (cp >= 0x05D0 && cp <= 0x05EA) return true;
    if (cp >= 0x05F0 && cp <= 0x05F2) return true;
    if (cp >= 0x0621 && cp <= 0x063A) return true;
    if (cp >= 0x0641 && cp <= 0x064A) return true;
    if (cp >= 0x0671 && cp <= 0x06B7) return true;
    if (cp >= 0x06BA && cp <= 0x06BE) return true;
    if (cp >= 0x06C0 && cp <= 0x06CE) return true;
    if (cp >= 0x06D0 && cp <= 0x06D3) return true;
    if (cp >= 0x06E5 && cp <= 0x06E6) return true;
    if (cp >= 0x0905 && cp <= 0x0939) return true;
    if (cp >= 0x0958 && cp <= 0x0961) return true;
    if (cp >= 0x0985 && cp <= 0x098C) return true;
    if (cp >= 0x098F && cp <= 0x0990) return true;
    if (cp >= 0x0993 && cp <= 0x09A8) return true;
    if (cp >= 0x09AA && cp <= 0x09B0) return true;
    if (cp >= 0x09B6 && cp <= 0x09B9) return true;
    if (cp >= 0x09DC && cp <= 0x09DD) return true;
    if (cp >= 0x09DF && cp <= 0x09E1) return true;
    if (cp >= 0x09F0 && cp <= 0x09F1) return true;
    if (cp >= 0x0A05 && cp <= 0x0A0A) return true;
    if (cp >= 0x0A0F && cp <= 0x0A10) return true;
    if (cp >= 0x0A13 && cp <= 0x0A28) return true;
    if (cp >= 0x0A2A && cp <= 0x0A30) return true;
    if (cp >= 0x0A32 && cp <= 0x0A33) return true;
    if (cp >= 0x0A35 && cp <= 0x0A36) return true;
    if (cp >= 0x0A38 && cp <= 0x0A39) return true;
    if (cp >= 0x0A59 && cp <= 0x0A5C) return true;
    if (cp >= 0x0A72 && cp <= 0x0A74) return true;
    if (cp >= 0x0A85 && cp <= 0x0A8B) return true;
    if (cp >= 0x0A8F && cp <= 0x0A91) return true;
    if (cp >= 0x0A93 && cp <= 0x0AA8) return true;
    if (cp >= 0x0AAA && cp <= 0x0AB0) return true;
    if (cp >= 0x0AB2 && cp <= 0x0AB3) return true;
    if (cp >= 0x0AB5 && cp <= 0x0AB9) return true;
    if (cp >= 0x0B05 && cp <= 0x0B0C) return true;
    if (cp >= 0x0B0F && cp <= 0x0B10) return true;
    if (cp >= 0x0B13 && cp <= 0x0B28) return true;
    if (cp >= 0x0B2A && cp <= 0x0B30) return true;
    if (cp >= 0x0B32 && cp <= 0x0B33) return true;
    if (cp >= 0x0B36 && cp <= 0x0B39) return true;
    if (cp >= 0x0B5C && cp <= 0x0B5D) return true;
    if (cp >= 0x0B5F && cp <= 0x0B61) return true;
    if (cp >= 0x0B85 && cp <= 0x0B8A) return true;
    if (cp >= 0x0B8E && cp <= 0x0B90) return true;
    if (cp >= 0x0B92 && cp <= 0x0B95) return true;
    if (cp >= 0x0B99 && cp <= 0x0B9A) return true;
    if (cp >= 0x0B9E && cp <= 0x0B9F) return true;
    if (cp >= 0x0BA3 && cp <= 0x0BA4) return true;
    if (cp >= 0x0BA8 && cp <= 0x0BAA) return true;
    if (cp >= 0x0BAE && cp <= 0x0BB5) return true;
    if (cp >= 0x0BB7 && cp <= 0x0BB9) return true;
    if (cp >= 0x0C05 && cp <= 0x0C0C) return true;
    if (cp >= 0x0C0E && cp <= 0x0C10) return true;
    if (cp >= 0x0C12 && cp <= 0x0C28) return true;
    if (cp >= 0x0C2A && cp <= 0x0C33) return true;
    if (cp >= 0x0C35 && cp <= 0x0C39) return true;
    if (cp >= 0x0C60 && cp <= 0x0C61) return true;
    if (cp >= 0x0C85 && cp <= 0x0C8C) return true;
    if (cp >= 0x0C8E && cp <= 0x0C90) return true;
    if (cp >= 0x0C92 && cp <= 0x0CA8) return true;
    if (cp >= 0x0CAA && cp <= 0x0CB3) return true;
    if (cp >= 0x0CB5 && cp <= 0x0CB9) return true;
    if (cp >= 0x0CE0 && cp <= 0x0CE1) return true;
    if (cp >= 0x0D05 && cp <= 0x0D0C) return true;
    if (cp >= 0x0D0E && cp <= 0x0D10) return true;
    if (cp >= 0x0D12 && cp <= 0x0D28) return true;
    if (cp >= 0x0D2A && cp <= 0x0D39) return true;
    if (cp >= 0x0D60 && cp <= 0x0D61) return true;
    if (cp >= 0x0E01 && cp <= 0x0E2E) return true;
    if (cp >= 0x0E32 && cp <= 0x0E33) return true;
    if (cp >= 0x0E40 && cp <= 0x0E45) return true;
    if (cp >= 0x0E81 && cp <= 0x0E82) return true;
    if (cp >= 0x0E87 && cp <= 0x0E88) return true;
    if (cp >= 0x0E94 && cp <= 0x0E97) return true;
    if (cp >= 0x0E99 && cp <= 0x0E9F) return true;
    if (cp >= 0x0EA1 && cp <= 0x0EA3) return true;
    if (cp >= 0x0EAA && cp <= 0x0EAB) return true;
    if (cp >= 0x0EAD && cp <= 0x0EAE) return true;
    if (cp >= 0x0EB2 && cp <= 0x0EB3) return true;
    if (cp >= 0x0EC0 && cp <= 0x0EC4) return true;
    if (cp >= 0x0F40 && cp <= 0x0F47) return true;
    if (cp >= 0x0F49 && cp <= 0x0F69) return true;
    if (cp >= 0x10A0 && cp <= 0x10C5) return true;
    if (cp >= 0x10D0 && cp <= 0x10F6) return true;
    if (cp >= 0x1102 && cp <= 0x1103) return true;
    if (cp >= 0x1105 && cp <= 0x1107) return true;
    if (cp >= 0x110B && cp <= 0x110C) return true;
    if (cp >= 0x110E && cp <= 0x1112) return true;
    if (cp >= 0x1154 && cp <= 0x1155) return true;
    if (cp >= 0x115F && cp <= 0x1161) return true;
    if (cp >= 0x116D && cp <= 0x116E) return true;
    if (cp >= 0x1172 && cp <= 0x1173) return true;
    if (cp >= 0x11AE && cp <= 0x11AF) return true;
    if (cp >= 0x11B7 && cp <= 0x11B8) return true;
    if (cp >= 0x11BC && cp <= 0x11C2) return true;
    if (cp >= 0x1E00 && cp <= 0x1E9B) return true;
    if (cp >= 0x1EA0 && cp <= 0x1EF9) return true;
    if (cp >= 0x1F00 && cp <= 0x1F15) return true;
    if (cp >= 0x1F18 && cp <= 0x1F1D) return true;
    if (cp >= 0x1F20 && cp <= 0x1F45) return true;
    if (cp >= 0x1F48 && cp <= 0x1F4D) return true;
    if (cp >= 0x1F50 && cp <= 0x1F57) return true;
    if (cp >= 0x1F5F && cp <= 0x1F7D) return true;
    if (cp >= 0x1F80 && cp <= 0x1FB4) return true;
    if (cp >= 0x1FB6 && cp <= 0x1FBC) return true;
    if (cp >= 0x1FC2 && cp <= 0x1FC4) return true;
    if (cp >= 0x1FC6 && cp <= 0x1FCC) return true;
    if (cp >= 0x1FD0 && cp <= 0x1FD3) return true;
    if (cp >= 0x1FD6 && cp <= 0x1FDB) return true;
    if (cp >= 0x1FE0 && cp <= 0x1FEC) return true;
    if (cp >= 0x1FF2 && cp <= 0x1FF4) return true;
    if (cp >= 0x1FF6 && cp <= 0x1FFC) return true;
    if (cp >= 0x212A && cp <= 0x212B) return true;
    if (cp >= 0x2180 && cp <= 0x2182) return true;
    if (cp >= 0x3041 && cp <= 0x3094) return true;
    if (cp >= 0x30A1 && cp <= 0x30FA) return true;
    if (cp >= 0x3105 && cp <= 0x312C) return true;
    if (cp >= 0xAC00 && cp <= 0xD7A3) return true;
    if (cp == 0x09B2)
    || (cp == 0x0386) 
    || (cp == 0x038C) 
    || (cp == 0x03DA) 
    || (cp == 0x03DC) 
    || (cp == 0x03DE) 
    || (cp == 0x03E0) 
    || (cp == 0x0559) 
    || (cp == 0x06D5) 
    || (cp == 0x093D) 
    || (cp == 0x0A5E) 
    || (cp == 0x0A8D) 
    || (cp == 0x0ABD) 
    || (cp == 0x0AE0) 
    || (cp == 0x0B3D) 
    || (cp == 0x0B9C) 
    || (cp == 0x0CDE) 
    || (cp == 0x0E30) 
    || (cp == 0x0E84) 
    || (cp == 0x0E8A) 
    || (cp == 0x0E8D) 
    || (cp == 0x0EA5) 
    || (cp == 0x0EA7) 
    || (cp == 0x0EB0) 
    || (cp == 0x0EBD) 
    || (cp == 0x1100) 
    || (cp == 0x1109) 
    || (cp == 0x113C) 
    || (cp == 0x113E) 
    || (cp == 0x1140) 
    || (cp == 0x114C) 
    || (cp == 0x114E) 
    || (cp == 0x1150) 
    || (cp == 0x1159) 
    || (cp == 0x1163) 
    || (cp == 0x1165) 
    || (cp == 0x1167) 
    || (cp == 0x1169) 
    || (cp == 0x1175) 
    || (cp == 0x119E) 
    || (cp == 0x11A8) 
    || (cp == 0x11AB) 
    || (cp == 0x11BA) 
    || (cp == 0x11EB) 
    || (cp == 0x11F0) 
    || (cp == 0x11F9) 
    || (cp == 0x1F59) 
    || (cp == 0x1F5B) 
    || (cp == 0x1F5D) 
    || (cp == 0x1FBE) 
    || (cp == 0x2126) 
    || (cp == 0x212E)
    then return true;

    return false;
}

xml_is_ideographic :: (s: string) -> bool {
    cp, bytes, success := character_utf8_to_utf32(s.data, s.count);
    if success != .CONVERSION_OK return false;
    return xml_is_ideographic(cp);
}

xml_is_ideographic :: (cp: u32) -> bool {
    if (cp >= 0x4E00 && cp <= 0x9FA5)
    || (cp == 0x3007)
    || (cp >= 0x3021 && cp <= 0x3029)
    then return true;
    return false;
}

xml_is_combiningchar :: (s: string) -> bool {
    cp, bytes, success := character_utf8_to_utf32(s.data, s.count);
    if success != .CONVERSION_OK return false;
    return xml_is_combiningchar(cp);
}

xml_is_combiningchar :: (cp: u32) -> bool {
    return false;
    // TODO implement
    // [#x0300-#x0345] | [#x0360-#x0361] | [#x0483-#x0486] | [#x0591-#x05A1] | [#x05A3-#x05B9] | [#x05BB-#x05BD] | #x05BF | [#x05C1-#x05C2] | #x05C4 | [#x064B-#x0652] | #x0670 | [#x06D6-#x06DC] | [#x06DD-#x06DF] | [#x06E0-#x06E4] | [#x06E7-#x06E8] | [#x06EA-#x06ED] | [#x0901-#x0903] | #x093C | [#x093E-#x094C] | #x094D | [#x0951-#x0954] | [#x0962-#x0963] | [#x0981-#x0983] | #x09BC | #x09BE | #x09BF | [#x09C0-#x09C4] | [#x09C7-#x09C8] | [#x09CB-#x09CD] | #x09D7 | [#x09E2-#x09E3] | #x0A02 | #x0A3C | #x0A3E | #x0A3F | [#x0A40-#x0A42] | [#x0A47-#x0A48] | [#x0A4B-#x0A4D] | [#x0A70-#x0A71] | [#x0A81-#x0A83] | #x0ABC | [#x0ABE-#x0AC5] | [#x0AC7-#x0AC9] | [#x0ACB-#x0ACD] | [#x0B01-#x0B03] | #x0B3C | [#x0B3E-#x0B43] | [#x0B47-#x0B48] | [#x0B4B-#x0B4D] | [#x0B56-#x0B57] | [#x0B82-#x0B83] | [#x0BBE-#x0BC2] | [#x0BC6-#x0BC8] | [#x0BCA-#x0BCD] | #x0BD7 | [#x0C01-#x0C03] | [#x0C3E-#x0C44] | [#x0C46-#x0C48] | [#x0C4A-#x0C4D] | [#x0C55-#x0C56] | [#x0C82-#x0C83] | [#x0CBE-#x0CC4] | [#x0CC6-#x0CC8] | [#x0CCA-#x0CCD] | [#x0CD5-#x0CD6] | [#x0D02-#x0D03] | [#x0D3E-#x0D43] | [#x0D46-#x0D48] | [#x0D4A-#x0D4D] | #x0D57 | #x0E31 | [#x0E34-#x0E3A] | [#x0E47-#x0E4E] | #x0EB1 | [#x0EB4-#x0EB9] | [#x0EBB-#x0EBC] | [#x0EC8-#x0ECD] | [#x0F18-#x0F19] | #x0F35 | #x0F37 | #x0F39 | #x0F3E | #x0F3F | [#x0F71-#x0F84] | [#x0F86-#x0F8B] | [#x0F90-#x0F95] | #x0F97 | [#x0F99-#x0FAD] | [#x0FB1-#x0FB7] | #x0FB9 | [#x20D0-#x20DC] | #x20E1 | [#x302A-#x302F] | #x3099 | #x309A
}

xml_is_extender :: (cp: u32) -> bool {
    return false;
    // TODO: Implement
    // #x00B7 | #x02D0 | #x02D1 | #x0387 | #x0640 | #x0E46 | #x0EC6 | #x3005 | [#x3031-#x3035] | [#x309D-#x309E] | [#x30FC-#x30FE]    
}

xml_is_letter :: (cp: u32) -> bool {
    return xml_is_basechar(cp) || xml_is_ideographic(cp);
}

xml_is_in :: (cp: u32, s: string) -> bool {
    cmp := s;
    while true {
        chr, success := utf8_next_character(*cmp);
        if success != .CONVERSION_OK return false;
        if chr == cp return true;
    }
    return false;
}

xml_is_namechar :: (cp: u32) -> bool {
    return xml_is_letter(cp) 
        || xml_is_digit(cp) 
        || xml_is_in(cp, ".-_:")
        || xml_is_combiningchar(cp)
        || xml_is_extender(cp);
}

xml_is_namechar :: (s: string) -> bool {
    cp, bytes, success := character_utf8_to_utf32(s.data, s.count);
    if success != .CONVERSION_OK return false;
    return xml_is_namechar(cp);
}