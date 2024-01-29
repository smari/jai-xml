#import,file "../module.jai";
#import "Basic";

main :: () {
    root, result := xml_parse_file("traverse.xml");
    if result.status != .ok {
        print("Problem with XML file: %\n", result.status);
        return;
    }

    start := root.first_child.next_sibling.first_child;
    print("Starting at %\n", start.name);

    print("Walking the XML from our start node, depth first:\n");
    for node:start {
        print("<%:% {% attrs}>\n", 
                node.type, node.name, node.attributes.count);
    }

    xml_free(root);
}
