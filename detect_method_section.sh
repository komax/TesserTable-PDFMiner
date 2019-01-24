#!/usr/bin/env bash

#grep --extended-regexp --line-number --files-without-match "^([0-9]+.?\s*)?(Method|METHOD|Materials and methods|MATERIALS AND METHODS|Material and methods|Study site and methods|Materials methods|Study Area and Methods|M E T H O D S|Material and Methods|STUDY SITE AND METHODS|Materials and Methods|Study area and methods|Study sites and methods|MATERIAL AND METHODS|MATERIALS AN D METHODS|Sample sites and methods)" output/*/ocr_text.txt | less --LINE-NUMBERS
grep --extended-regexp --count --file=method_heading_pattern.txt $1/*/ocr_text.txt | grep --extended-regexp -v ':[01]$' > methods_counts.txt

for f in `cut -f1 -d ':' methods_counts.txt`;
do
    ./occurences_methods.sh $f
done
