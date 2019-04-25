#!/bin/bash

PNG_PATH=$1
HOCR_PATH=$2
# PATH_WITHOUT_EXT without filetype extension.
OUTBASE=$(dirname $HOCR_PATH)
BASE_NAME=$(basename $HOCR_PATH .hocr)
PATH_WITHOUT_EXT="$OUTBASE/$BASE_NAME"

# Call tesseract to generate hocr and txt file
tesseract $PNG_PATH $PATH_WITHOUT_EXT hocr txt

PAPER_PATH=$3
mv $PATH_WITHOUT_EXT.txt $PAPER_PATH/ocr-txt/$BASE_NAME.txt