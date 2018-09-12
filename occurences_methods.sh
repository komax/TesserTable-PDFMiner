#!/usr/bin/env bash

echo $1
grep --extended-regexp --line-number --file=method_heading_pattern.txt $1
echo -e "\n"