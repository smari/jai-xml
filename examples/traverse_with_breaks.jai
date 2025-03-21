#import,file "../module.jai";
#import "Basic";

callback_break_on_bar :: (node: *XMLNode, userdata : *void = null) -> XMLNodeWalkResult {
    print("<%:% {% attrs}>\n", node.type, node.name, node.attributes.count);
    if node.name == "bar" {
        return .Break;
    }
    return .Continue;
}

callback_only_descend_children_on_bar :: (node: *XMLNode, userdata : *void = null) -> XMLNodeWalkResult {
    print("<%:% {% attrs}>\n", node.type, node.name, node.attributes.count);
    if node.name == "bar" {
        return .OnlyChildren;
    }
    return .Continue;
}

callback_only_descend_siblings_on_bar :: (node: *XMLNode, userdata : *void = null) -> XMLNodeWalkResult {
    print("<%:% {% attrs}>\n", node.type, node.name, node.attributes.count);
    if node.name == "bar" {
        return .OnlySiblings;
    }
    return .Continue;
}


main :: () {
    root, result := xml_parse_file("traverse.xml");
    if result.status != .ok {
        print("Problem with XML file: %\n", result.status);
        return;
    }

    print("Breadth first, break on bar:\n");
    xml_walk_breadthfirst(root, callback_break_on_bar);
    print("-----\nDepth first, break on bar:\n");
    xml_walk_depthfirst(root, callback_break_on_bar);
    print("-----\nBreadth first, only descend children of bar:\n");
    xml_walk_breadthfirst(root, callback_only_descend_children_on_bar);
    print("-----\nDepth first, only descend children of bar:\n");
    xml_walk_depthfirst(root, callback_only_descend_children_on_bar);
    print("-----\nBreadth first, only descend siblings of bar:\n");
    xml_walk_breadthfirst(root, callback_only_descend_siblings_on_bar);
    print("-----\nDepth first, only descend siblings of bar:\n");
    xml_walk_depthfirst(root, callback_only_descend_siblings_on_bar);

    xml_free(root);
}
