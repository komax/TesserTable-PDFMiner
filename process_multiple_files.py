#!/usr/bin/env python

import argparse

from pathlib import Path
from subprocess import call


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


def create_output_directory(pdf_path):
    file_name = file_name_without_ext(pdf_path)
    out_directory = Path(OUT_DIR) / file_name
    out_directory.mkdir(parents=True, exist_ok=True)
    return out_directory


def handle_paper(pdf_path):
    out_directory = str(create_output_directory(pdf_path))
    basename_pdf = file_name_without_ext(pdf_path)
    qsub_call = ['qsub',
         '-N', f'table-extract-{basename_pdf[:20]}',
         '/home/konzack/scripts/table-extract-pdf.sh']
    #func_call = ['./process-pdf.sh', out_directory, str(pdf_path)]
    qsub_call.extend([out_directory, str(pdf_path)])
    print(" ".join(qsub_call))
    #call(func_call)
    call(qsub_call)


OUT_DIR = "./output"


def main():
    parser = set_up_argparser()
    args = parser.parse_args()

    global OUT_DIR
    if args.output_directory:
        OUT_DIR = args.output_directory

    pdfs = select_pdfs(args.inputdir)

    for pdf_path in pdfs:
        handle_paper(pdf_path)

    # p = Pool(4)
    # p.map(handle_paper, pdfs)
    #
    # for i, p in enumerate(pdfs):
    #     if str(p.stem).startswith("Andresen"):
    #         print i
    #
    # print pdfs[3]
    # handle_paper(pdfs[3])

    #call(['./preprocess.sh', 'output/henry_et_al._2007', '/Users/mk21womu/Dropbox/Habitat loss meta-analysis/good_datasets/references/henry et al. 2007.pdf'])
    #extract_tables('output/henry_et_al._2007')


if __name__ == '__main__':
    main()
