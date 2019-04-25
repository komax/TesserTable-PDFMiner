from scripts.utils import PDFArtefacts
from table_extract import extract_tables

OUTDIR = "ocr_output"

filenames = glob_wildcards("pdfs/{filename}.pdf")

def all_pdftotext_files(wildcards):
    return list(map(lambda p: f"{OUTDIR}/{p}/pdftotext.txt", wildcards.filename))


def all_ocr_text_files(wildcards):
    return list(map(lambda p: f"{OUTDIR}/{p}/ocr_text.txt", wildcards.filename))


def all_table_extract_done(wildcards):
    res = []
    for filename in wildcards.filename:
        res.append(f"{OUTDIR}/{filename}/table_extract.done")
    return res


rule all:
    input:
        pdftotxts=all_pdftotext_files(filenames)
    run:
        for txt in input.pdftotxts:
            print(f"Used pdftotext for file: {txt}")

rule ocr_all:
    input:
        ocr_txts=all_ocr_text_files(filenames)
    run:
        for txt in input.ocr_txts:
            print(f"Generated OCR text for file: {txt}")

rule table_extract_all:
    input:
        all_table_extract_done(filenames)
    run:
        print("Done with extracting tables")


rule cp_pdf:
    input:
        pdf="pdfs/{pdf_file}.pdf"
    output:
        pdf="ocr_output/{pdf_file}/orig.pdf"
    shell:
        "cp {input.pdf} {output.pdf}"

rule pdf_to_text:
    input:
        pdf="ocr_output/{pdf_file}/orig.pdf"
    output:
        txt="ocr_output/{pdf_file}/pdftotext.txt"
    run:
        shell("pdftotext {input.pdf} - -enc UTF-8 > {output.txt}")


rule pdf_to_png_page:
    input:
        pdf="ocr_output/{filename}/orig.pdf"
    output:
        png="ocr_output/{filename}/png/page_{page_no}.png"
    wildcard_constraints:
        page_no="\d+"
    run:
        shell("scripts/pdf2png_page.sh {wildcards.page_no} ocr_output/{wildcards.filename}/png {input.pdf}")

rule ocr_page:
    input:
        png="ocr_output/{filename}/png/page_{page_no}.png"
    output:
        hocr="ocr_output/{filename}/hocr/page_{page_no}.hocr",
        txt="ocr_output/{filename}/ocr-txt/page_{page_no}.txt"
    wildcard_constraints:
        page_no="\d+"
    run:
        shell("scripts/ocr_page.sh {input.png} {output.hocr} ocr_output/{wildcards.filename}")
        # FIXME Employ gnu parallel.

# TODO OCR all pages in parallel.

rule merge_ocr_txt:
    input:
        lambda wildcards: PDFArtefacts(f"pdfs/{wildcards.filename}.pdf", OUTDIR).ocr_text(),
        pdf="ocr_output/{filename}/orig.pdf"
    output:
        ocr_txt="ocr_output/{filename}/ocr_text.txt"
    run:
        txts =input[0:-1]
        shell("cat {txts} > {output.ocr_txt}")


rule table_extract:
    input:
        lambda wildcards: PDFArtefacts(f"pdfs/{wildcards.filename}.pdf", OUTDIR).hocr(),
        pdf="ocr_output/{filename}/orig.pdf"
    output:
        directory("ocr_output/{filename}/hocr-ts"),
        touch("ocr_output/{filename}/table_extract.done")
    #output:
        #hocrs=expand("ocr_output/{{filename}}/hocr-ts/page_{page_no}.hocr", page_no=()
    run:
        print("///////")
        print(input.pdf)
        print("////////")
        print("----------")
        print(output)
        print("----------")
        extract_tables(f"{OUTDIR}/{wildcards.filename}")
        #FIXME Implement this.
