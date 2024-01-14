# JXML

This is an XML parser and DOM handling library for Jai.


# Features and Speed

Parses most XML correctly. Fails on certain rare `<!DOCTYPE>` declarations. Doesn't handle encodings other than UTF-8 and ASCII, except by accident.

Benchmarked on a test suite based on the XML conformance tests, with 3111 tests, of which 90% pass. 

Average speed is 113µs per test.

```
Runtime: 351301 µs.
Passed: 2818 (90.5818%)
Failed: 293 (9.4182%)
Total : 3111
```

To run the tests/benchmarks, compile `test.jai` and run. We don't distribute most of the test data files, so use `test_data/fetch.sh` to fetch them.

# Documentation

## Example use

```
#import "JXML";

main :: () {
    result, root := xml_parse("myfile.xml");
    if result.status != .ok {
        print("Problem with XML file: %\n", result.status);
    }

    for node:root {
        print("Walking the XML file, depth first: %\n", <<node);
    }

    xml_free(root);
}
```

## Parsing functions:
 * `xml_parse :: (buffer: string) -> XMLParseResult, *XMLNode, *XMLParser`
 * `xml_parse_file :: (file: string) -> XMLParseResult, *XMLNode`

## Node functions:
 * `node_allocate :: inline () -> *XMLNode`
 * `node_create :: (type: XMLNodeType) -> *XMLNode`
 * `node_free :: (node: *XMLNode)`
 * `node_append :: (child: *XMLNode, node: *XMLNode)`
 * `node_append_new :: (node: *XMLNode, type: XMLNodeType) -> *XMLNode`
 * `node_prepend :: (child: *XMLNode, node: *XMLNode)`
 * `node_insert_after :: (sibling: *XMLNode, node: *XMLNode)`
 * `node_insert_before :: (sibling: *XMLNode, node: *XMLNode)`
 * `node_remove :: (node: *XMLNode)`
 * `node_find_child_by_tag :: (node: *XMLNode, tag: string) -> *XMLNode`
 * `node_get_cdata :: (node: *XMLNode) -> string, bool`

## Attribute functions:
 * `attribute_allocate :: inline () -> *XMLAttribute`
 * `attribute_free :: (attrib: *XMLAttribute)`
 * `attribute_get :: (node: *XMLNode, name: string) -> *XMLAttribute`
 * `attribute_get_value :: (node: *XMLNode, name: string, default := "") -> string, bool`
 * `attribute_append :: (attr: *XMLAttribute, node: *XMLNode)`
 * `attribute_append :: (node: *XMLNode, key: string, value: string)`
 * `attribute_prepend :: (attr: *XMLAttribute, node: *XMLNode)`
 * `attribute_insert_after :: (attr: *XMLAttribute, node: *XMLNode)`
 * `attribute_insert_before :: (attr: *XMLAttribute, node: *XMLNode)`
 * `attribute_remove :: (attr: *XMLAttribute, node: *XMLNode)`
 * `attribute_append_new :: (node: *XMLNode) -> *XMLAttribute`

## Iterators:
 * `xml_walk_depthfirst :: (node: *XMLNode, callback: XMLNodeWalkCallback)`
 * `xml_walk_breadthfirst :: (node: *XMLNode, callback: XMLNodeWalkCallback)`
 * `for_expansion :: (node: *XMLNode, body: Code, flags: For_Flags)`


# TODO

 * [ ] Verify that free-methods are working right
 * [ ] Add support for ISO-8859
 * [ ] Add support for UTF-16
 * [ ] Improve speed of UTF-8 to UTF-32 conversion
 * [ ] Improve speed of Unicode character class matching

# Authors

 * Smári McCarthy

 # License

 Copyright 2014 Smári McCarthy

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.