#import,file "../module.jai";
#import "Basic";

// This verifies that `continue` and `break` work correctly.
// Based on bug report in issue #3 by Valigo
// https://github.com/smari/jai-xml/issues/3

main :: () {
    xml :: #string DONE
<?xml version="1.0" encoding="UTF-8"?>
        <foo>
          <bar>A</bar>
          <bar>B</bar>
          <baz>Funky</baz>
          <xyzzy>
            <bar>D</bar>
          </xyzzy>
          <bar>E</bar>
        </foo>
    DONE

    print("XML: '%'\n", xml);

    {
        print("Visit all nodes: (regular iteration)\n");
        root, result := xml_parse(xml);
        for root {
            print("<% %>%\n", it.name, it.type, it.value);
        }
    }
    {
        print("Visit all nodes (with continue):\n");
        root, result := xml_parse(xml);
        for root {
            print("<% %>%\n", it.name, it.type, it.value);
            if it_index > 20 break;
            continue;
        }
    }

    {
        print("Break after visiting the first node (break):\n");
        root, result := xml_parse(xml);
        for root {
            print("<% %>%\n", it.name, it.type, it.value);
            break;
        }
    }

    {
        print("Skip baz node:\n");
        root, result := xml_parse(xml);
        for root {
            if it.name == "baz" continue;
            print("<% %>%\n", it.name, it.type, it.value);
        }
    }

}

