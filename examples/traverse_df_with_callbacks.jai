#import,file "../module.jai";
#import "Basic";

callback :: (node: *XMLNode) {
    print("<%:% {% attrs}>\n", node.type, node.name, node.attributes.count);
}

main :: () {
    root, result := xml_parse_file("traverse.xml");
    if result.status != .ok {
        print("Problem with XML file: %\n", result.status);
        return;
    }

    print("Walking the XML file, depth first, using callback:\n");

    xml_walk_depthfirst(root, callback);

    xml_free(root);
}
