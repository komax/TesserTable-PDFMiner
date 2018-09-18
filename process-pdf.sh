#!/usr/bin/env bash

if [ $# -lt 2 ]
  then echo -e "Please provide an output directory and an input PDF. Example: process-pdf ./ocrd ~/Downloads/document.pdf"
  exit 1
fi

echo "Starting to preprocess $2"
# Preprocess the pdf using tesseract.
./preprocess.sh $1 $2 && echo "Completed OCR on $2"

# Autodetect tables.
echo "Starting to extract tables $1"
python ./do_extract.py $1 && echo "Completed extracting tables $1"
