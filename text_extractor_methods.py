#! /usr/bin/env python


import argparse
import re
from pathlib import Path

from bs4 import BeautifulSoup


def set_up_argparser():
    parser = argparse.ArgumentParser()
    parser.add_argument('inputdir', help="input directory containing hocr files")
    parser.add_argument("-o", "--output", help="output file containing the method section")
    return parser


def select_hocr_files(input_dir):
    return sorted(Path(input_dir).glob('*.html'))


def build_methods_regex():
    terms = ["Method", "METHOD", "Materials and Methods",
             "MATERIALS AND METHODS", "Materials methods",
             "Material and methods",
             "Study site and methods", "Study Area and Methods",
             "M E T H O D S", "Material and Methods", "STUDY SITE AND METHODS",
             "Materials and Methods", "Study area and methods",
             "Study sites and methods", "MATERIAL AND METHODS",
             "MATERIALS AN D METHODS", "Sample sites and methods"]
    regex = re.compile(r'^([0-9]+.?\s*)?({})'.format("|".join(terms)))
    #print(regex)
    return regex


def handle_page(page_path):
    with open(page_path) as hocr:
        page_soup = BeautifulSoup(hocr.read(), 'html.parser')
        regex = build_methods_regex()
        for area in page_soup.find_all("div", "ocr_carea"):
            for i, line in enumerate(area.find_all("span", "ocr_line")):
                line_text = " ".join(map(
                    lambda e: e.text,
                    list(line.find_all("span", "ocrx_word")
                         )))
                match = regex.findall(line_text)
                if match:
                    print(match)
                #print((i, line_text))

            #     for word in line.find_all("span", "ocrx_word"):
            #         pass
            #     text = " ".join(map(lambda e: e.text, list(line.find_all("span", "ocrx_word"))))
            #     print(text)
            #     print("\n\n\n")

                # print("Famous first word: {}".format(line.contents[0]))
                # for word in line.find_all("span", "ocrx_word", id='word_1_561'):
                #     print(word['title'])
                #     print(word['id'])

        #print(page_soup)
        #print(len(page_soup.find_all("span", "ocrx_word")))


def main():
    parser = set_up_argparser()
    args = parser.parse_args()
    hocr_files = select_hocr_files(args.inputdir)
    # Sort files by page number.
    hocr_files.sort(key=lambda f: int(''.join(filter(str.isdigit, f.stem))))

    for hocr in hocr_files:
        print("Handle page {}".format(hocr))
        handle_page(hocr)


if __name__ == "__main__":
    main()
