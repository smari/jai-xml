#import,file "../module.jai";
#import "Basic";

// This verifies that `continue` works correctly.
// Based on bug report in issue #3 by Valigo
// https://github.com/smari/jai-xml/issues/3

main :: () {
    xml :: #string DONE
<?xml version="1.0" encoding="UTF-8"?>
        <foo>
        </foo>
    DONE

    root, result := xml_parse(xml);
    for root {
        print("%\n", it.*);
        continue;
    }
}

