#!/bin/bash

PNG_PATH=$1
#echo $PNG_PATH
HOCR_PATH=$2
#echo $HOCR_PATH
# PATH_WITHOUT_EXT without filetype extension.
OUTBASE=$(dirname $HOCR_PATH)
BASE_NAME=$(basename $HOCR_PATH .hocr)
PATH_WITHOUT_EXT="$OUTBASE/$BASE_NAME"
#echo $OUTBASE
echo "tesseract $PNG_PATH $PATH_WITHOUT_EXT hocr txt"
# Call tesseract to generate hocr and txt file
tesseract $PNG_PATH $PATH_WITHOUT_EXT hocr txt

PAPER_PATH=$3
mv $PATH_WITHOUT_EXT.txt $PAPER_PATH/ocr-txt/$BASE_NAME.txt
echo "mv $PATH_WITHOUT_EXT.txt $PAPER_PATH/ocr-txt/$BASE_NAME.txt"