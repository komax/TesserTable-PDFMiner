#!/bin/bash

PAGE_NO=$1
OUTDIR=$2
PDF=$3
gs -dFirstPage=$PAGE_NO -dLastPage=$PAGE_NO -dBATCH -dNOPAUSE -sDEVICE=png16m -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -r600 -sOutputFile="$OUTDIR/page_$PAGE_NO.png" "$PDF"
