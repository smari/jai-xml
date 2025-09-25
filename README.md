# JXML

This is an XML parser and DOM handling library for Jai.
	
# Versions

Rather than using version numbers that mean practically nothing, we'll just log the dates of changes.

 * 2025-09-25: Made `USE_SIMD_STRING_SEARCH` into a module parameter, eliminating `settings.jai`. It defaults to being on, as this results in a ~17% speedup. Added documentation. Fixes issue #5.
 * 2025-03-21: Updates for Jai 0.2.010, including %% -> \% in prints. Fixed bug in `for_expansion`. Resolved feature request [#4](https://github.com/smari/jai-xml/issues/4) on user data and stop condition for walk callbacks, thanks again valigo. Note: This changes the signature for `XMLNodeWalkCallback`, which can break your builds. Sorry about that. If this broke your build, please let me know, because I have no idea how many users this library has, so I don't know how important API stability is. In the future breaking changes will be made very carefully and incrementally, or avoided altogther. No changes to test coverage.
 * 2025-02-11: Fixed a few bugs in the for_expansion, and improved its documentation. Some other bugs had also been fixed in the interim. Thanks to valigo and caztanj for bug reports and fixes. Also updated parser and tests a bit. Now test results are: Passed: 3066 (98.935143%), Failed: 33 (1.06486%), Total : 3099.
 * 2024-06-22: Some API updates, in particular `node_find_child_by_tag` now allows an optional `from` parameter. Minor parser improvements for some educations. Thanks to Nozdrum for suggestions. Tests: 3110, Passed: 2831, Failed: 279.
 * 2024-01-29: Initial release. Tests: 3111, Pass: 2818, Fail: 293

# Features and Speed

Parses most well formed XML correctly. Fails on certain rare `<!DOCTYPE>` declarations. Doesn't handle encodings other than UTF-8 and ASCII, except by accident.

Benchmarked on a test suite based on the XML conformance tests, with 3099 tests, of which 99% pass. 

Average speed is 20.59µs per test.

```
Runtime: 63823 µs.
Passed: 3066 (98.935143%)
Failed: 33 (1.06486%)
Total : 3099
```

To run the tests/benchmarks, compile `test.jai` and run. Benchmark numbers obtained with `-release` flag. We don't distribute most of the test data files, so use `test_data/fetch.sh` to fetch them.

# Documentation

## Example use

See examples in the `examples/` directory.

Note that this module takes the module parameter `USE_SIMD_STRING_SEARCH`, which relies on x86-64 assembly. Set it to false to use this library on non-x86 architectures (e.g. modern Macs)

## Looping

While you can traverse the XML hierarchy manually, there are both callback-based walkers and a `for_expansion` defined. 

The for expansion allows you to run `for` on a node and it will walk its children, depth first. Note that `continue` will continue the walk, but will *not* skip decent into the children of the current node. At some point it might be interesting to have an iterator where `continue` skips descent, but for now if you want to do this you'll have to roll your own.

`XMLNodeWalkCallback` functions should return `.Continue` to continue, `.Break` to stop descending, or either `.OnlyChildren` or `.OnlySiblings` to only continue to recurse children or siblings respectively. There is currently no mechanism to stop all iteration on the `xml_walk_depthfirst` or `xml_walk_breadthfirst` functions.

Note: The depth-first callback walker will visit children in the reverse order of their parents. This may seem confusing, and should probably be changed, but it's the easiest way to implement this.


## Parsing functions:
 * `xml_parse :: (buffer: string) -> *XMLNode, XMLParseResult`
 * `xml_parse_file :: (file: string) -> *XMLNode, XMLParseResult`

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
 * `node_find_child_by_tag :: (node: *XMLNode, tag: string, from: *XMLNode = null) -> *XMLNode`
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
 
## Writing functions:
 * `xml_write :: (node: *XMLNode, indent_str := "  ") -> string`

# TODO

 * [ ] Add support for ISO-8859
 * [ ] Add support for UTF-16
 * [ ] Improve speed of UTF-8 to UTF-32 conversion
 * [ ] Add XPath support

# Authors

 * Smári McCarthy

# License

Copyright 2024 Smári McCarthy. 

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

See LICENSE for details.
