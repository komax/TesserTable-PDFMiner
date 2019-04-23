#!/bin/bash

PNG_PATH=$1
HOCR_PATH=$2
# HOCR_PATH without filetype extension.
OUTBASE=${2%%.*}
echo $OUTBASE
# Call tesseract to generate hocr and txt file
tesseract $PNG_PATH $OUTBASE hocr txt

BASE_NAME=$(basename $HOCR_PATH .hocr)
PAPER_PATH=$3
mv $OUTBASE.txt $PAPER_PATH/ocr-txt/$BASE_NAME.txt