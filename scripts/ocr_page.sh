#!/bin/bash

PNG_PATH=$1
HOCR_PATH=$2
# PATH_WITHOUT_EXT without filetype extension.
OUTBASE=$(dirname $HOCR_PATH)
BASE_NAME=$(basename $HOCR_PATH .hocr)
PATH_WITHOUT_EXT="$OUTBASE/$BASE_NAME"

# Call tesseract to generate hocr and txt file
# TODO Describe https://github.com/tesseract-ocr/tesseract/issues/2312
# OMP_THREAD_LIMIT=1 allows only one thread to be used in tesseract
OMP_THREAD_LIMIT=1 tesseract $PNG_PATH $PATH_WITHOUT_EXT hocr txt

PAPER_PATH=$3
mv $PATH_WITHOUT_EXT.txt $PAPER_PATH/ocr-txt/$BASE_NAME.txt