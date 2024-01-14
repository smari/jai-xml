#!/bin/bash

# Get RSS feed tests:

mkdir -p test_data/rss

URLS=(
    "https://gizmodo.com/rss"
    "https://www.vox.com/rss/index.xml"
    "https://www.ft.com/rss/home"
    "http://feeds.arstechnica.com/arstechnica/index"
    "https://seekingalpha.com/market_currents.xml"
    "https://www.economist.com/rss"
    "https://techcrunch.com/feed/"
    "https://www.theverge.com/rss/index.xml"
    "https://feeds.businessinsider.com/custom/all"
    "https://www.politico.com/rss/politicopicks.xml"
    "https://hnrss.org/frontpage"
)

i=0
for url in "${URLS[@]}";
do
    echo -n "Fetching $url ..."
    ((i++))
    curl $url > test_data/rss/$i.xml
    echo " done"
done


# Get XML W3C Conformance Test Suite
(
    echo -n "Fetching W3C XML Conformance Test Suite ..."
    cd test_data
    curl -s https://www.w3.org/XML/Test/xmlts20130923.tar.gz > w3csuite.tar.gz
    tar -zxf w3csuite.tar.gz
    rm w3csuite.tar.gz
    cd xmlconf
    find . -name "*.dtd" -delete
    find . -name "*.ent" -delete
    find . -name "*.html" -delete
    echo " done"
)
