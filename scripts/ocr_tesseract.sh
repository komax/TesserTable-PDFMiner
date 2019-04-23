#!/bin/bash

PNG_PATH=$1
HOCR_PATH=$2
# HOCR_PATH without filetype extension.
OUTBASE=${2%%.*}
echo $OUTBASE
tesseract $PNG_PATH $OUTBASE hocr txt
