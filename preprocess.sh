#!/bin/bash

if [ $# -lt 2 ]
  then echo -e "Please provide an output directory and an input PDF. Example: pdf2hocr ./ocrd ~/Downloads/document.pdf"
  exit 1
fi

mkdir -p $1
mkdir -p $1/png
mkdir -p $1/tesseract
mkdir -p $1/tesseract-txt
mkdir -p $1/ocr_annotations
mkdir -p $1/table-detection
mkdir -p $1/tables

gs -dBATCH -dNOPAUSE -sDEVICE=png16m -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -r600 -sOutputFile="$1/png/page_%d.png" "$2"

cp "$2" "$1/orig.pdf"
pdftotext $1/orig.pdf - -enc UTF-8 > $1/text.txt


# from https://stackoverflow.com/questions/6481005/how-to-obtain-the-number-of-cpus-cores-in-linux-from-the-command-line
cpu_count=`getconf _NPROCESSORS_ONLN`

ls $1/png | grep -o '[0-9]\+' | parallel -j ${cpu_count} "./process-page.sh $1 {}"
#ls $1/png | grep -o '[0-9]\+' | parallel -j ${NSLOTS:-1} "./process-page.sh $1 {}"



if [ -f $1/plain_text.txt ]
then
    rm $1/plain_text.txt
fi
touch $1/plain_text.txt

tesseract_path="$1/tesseract-txt"

for i in `seq 1 300`;
do
    if [ -f $tesseract_path/page_$i.txt ]
    then
        cat $tesseract_path/page_$i.txt >> $1/plain_text.txt
    fi
done
