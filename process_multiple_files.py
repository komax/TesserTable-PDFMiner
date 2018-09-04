#!/usr/bin/env python

import argparse
import sys

from pathlib2 import Path
from subprocess import call
from multiprocessing import Pool

from table_extractor import extract_tables


def set_up_argparser():
    parser = argparse.ArgumentParser()
    parser.add_argument('inputdir', help="input directory containing multiple PDFs")
    parser.add_argument("-o", "--output-directory", type=str, help="output directory for the table-extract artefacts")
    return parser


def select_pdfs(input_dir):
    return sorted(Path(input_dir).glob('*.pdf'))


def file_name_without_ext(path):
    file_name = path.resolve().stem
    return file_name.replace(" ", "_").replace("'", "").replace(",", "")\
        .replace("(", "").replace(")", "")


def process_publication(pdf_path, out_dir):
    print "Starting to preprocess {} ...".format(pdf_path)
    func_call = ['./preprocess.sh', out_dir, pdf_path]
    call(func_call)
    print "Completed call: {}".format(" ".join(func_call))
    # print "Starting to extract tables {} ...".format(pdf_path)
    # extract_tables(out_dir)
    # print "Completed table extraction {} ...".format(pdf_path)


def create_output_directory(pdf_path):
    file_name = file_name_without_ext(pdf_path)
    out_directory = Path(OUT_DIR) / file_name
    out_directory.mkdir(parents=True, exist_ok=True)
    return out_directory


def handle_paper(pdf_path):
    out_directory = create_output_directory(pdf_path)
    process_publication(str(pdf_path), str(out_directory))


OUT_DIR = "./output"


def main():
    parser = set_up_argparser()
    args = parser.parse_args()

    global OUT_DIR
    if args.output_directory:
        OUT_DIR = args.output_directory

    pdfs = select_pdfs(args.inputdir)

    p = Pool(4)
    p.map(handle_paper, pdfs)

    # for pdf_path in pdfs:
    #     file_name = file_name_without_ext(pdf_path)
    #     out_directory = Path(out_dir) / file_name
    #     out_directory.mkdir(parents=True, exist_ok=True)
    #
    #     process_publication(str(pdf_path), str(out_directory))

    #call(['./preprocess.sh', 'output/henry_et_al._2007', '/Users/mk21womu/Dropbox/Habitat loss meta-analysis/good_datasets/references/henry et al. 2007.pdf'])
    #extract_tables('output/henry_et_al._2007')


if __name__ == '__main__':
    main()
