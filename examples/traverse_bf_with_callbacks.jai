#import,file "../module.jai";
#import "Basic";

callback :: (node: *XMLNode, userdata : *void = null) -> XMLNodeWalkResult {
    print("<%:% {% attrs}>\n", node.type, node.name, node.attributes.count);
    return .Continue;
}

main :: () {
    root, result := xml_parse_file("traverse.xml");
    if result.status != .ok {
        print("Problem with XML file: %\n", result.status);
        return;
    }

    print("Walking the XML file, breadth first, using callback:\n");

    xml_walk_breadthfirst(root, callback);

    xml_free(root);
}
