#import,file "../module.jai";
#import "Basic";

main :: () {
    root, result := xml_parse_file("traverse.xml");
    if result.status != .ok {
        print("Problem with XML file: %\n", result.status);
        return;
    }

    print("Walking the XML file, depth first:\n");
    for node:root {
        print("<%:% {% attrs}>\n", 
                node.type, node.name, node.attributes.count);
    }

    xml_free(root);
}
