# Optical Character Recognition (OCR) and table extraction
A tool which makes use of OCR to transform PDFs to [hocr files](http://kba.cloud/hocr-spec)
and classifies [areas in the hocr files](http://kba.cloud/hocr-spec/1.2/#sec-ocr_carea) as tables and other textual representations by using [table-extract](https://github.com/UW-Deepdive-Infrastructure/table-extract).


## Requirements
- conda (Anaconda or Miniconda)

## Install
### 1. Anaconda environment
1. Create a new environment, e.g., ```ocr-pdf``` and install all dependencies.
```bash
$ conda env create --name ocr-pdf --file environment.yaml
```

2. Activate the conda environment. Either use the anaconda navigator or use this command in your terminal:
```bash
$ conda activate ocr-pdf
```
or
```bash
$ source activate ocr-pdf
```
### 2. Set up input and output directories
The ```Snakefile``` uses three variables to specify:
 * ```INPUTDIR```: a directory containing all PDFs to process. Default: ```pdfs```
 * ```OUDIR```: this directory defines where to store the output of the processed PDFs. Default: ```output```
 * ```TMPDIR```: a directory to store temporary output files (in this pipeline: to omit pngs from pdfs). Reads ```$TMPDIR``` from bash environment. If it is not set, ```TMPDIR``` defaults to ```OUTIR```.


## Output format
Example: Presuming you want to process the pdf ```foo_bar_1999.pdf``` contained in ```INPUTDIR``` and ```OUTDIR``` is set to ```output```.

After running all rules, ```output/foo_bar_1999``` contains the following folders and files:
 * ```orig.pdf```: the input pdf
 * ```pdftotext.txt```: a txt file containing the output from ```pdftotext```
 * ```ocr_text.txt```: a text file from the OCR output
 * ```hocr/```: the directory containing the hocr files for each page of the pdf: ```page_1.hocr``` ... ```page_n.hocr``` (with being the last page of the pdf)
 * ```ocr-txt/```: generated from OCR. Same as ```hocr`` but plain text files per page.
 * ```hocr-ts```: this directory entails all pages ```page_1.hocr```, ```page_2.hocr```, ... from the pdf after executing ```table_extract```. ```table_extract``` enriches the hocr by two attributes in the hocr (example here): 
 ```hmtl
 ts:table-score="1" ts:type="caption"
 ```
 1.  ```ts:table-score``` is a score from how table-alike this area is. Higher scores hint that this area is like a table.
 2.  ```ts:type``` is a classification for this area. This attribute can have the following values: ```text block, table, line, caption, decoration, other```.

## Execute jobs with Snakemake
The configuration is stored in ```Snakefile```. Adjust ```-j <num_cores>``` in your snakemake calls to make use of multiple cores to run at the same time.

### 1. Single file processing
TODO
### 2. Batch processing of pdfs
TODO
### 3. Run ```table_extract```
TODO
