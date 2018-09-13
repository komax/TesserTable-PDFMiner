#! /usr/bin/env python


import argparse
from pathlib import Path

from  bs4 import BeautifulSoup


def set_up_argparser():
    parser = argparse.ArgumentParser()
    parser.add_argument('inputdir', help="input directory containing hocr files")
    parser.add_argument("-o", "--output", help="output file containing the method section")
    return parser


def select_hocr_files(input_dir):
    return sorted(Path(input_dir).glob('*.html'))


def main():
    parser = set_up_argparser()
    hocr_files = select_hocr_files(parser.inputdir)

    for hocr in hocr_files:
        print(hocr)


if __name__ == "__main__":
    main()
