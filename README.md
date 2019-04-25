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

## Execute jobs with Snakemake
The configuration is stored in ```Snakefile```. Adjust ```-j <num_cores>``` in your snakemake calls to make use of multiple cores to run at the same time.
