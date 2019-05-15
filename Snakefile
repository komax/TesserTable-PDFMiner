import os

from scripts.utils import PDFArtefacts
from table_extract import extract_tables, TableExtractConfig

# Paths for input data, temp data and output
INPUTDIR = os.environ.get("INPUTDIR", "pdfs")
OUTDIR = os.environ.get("OUTDIR", "output")
TMPDIR = os.environ.get("TMPDIR", OUTDIR)
#TMPDIR = "output"
if TMPDIR.endswith('/'):
    TMPDIR = TMPDIR[0:-1]

filenames = glob_wildcards(INPUTDIR+"/{filename}.pdf")


def all_files(computed_file, wildcards=filenames, outputdir=OUTDIR):
    res = []
    for filename in wildcards.filename:
        res.append(f"{outputdir}/{filename}/{computed_file}")
    return res


def all_pdftotext_files(wildcards=filenames):
    return all_files(computed_file='pdftotext.txt', wildcards=wildcards)


def all_ocr_text_files(wildcards=filenames):
    return all_files(computed_file='ocr_text.txt', wildcards=wildcards)


def all_tars(wildcards=filenames):
    return all_files(computed_file='pngs.tar.gz', wildcards=wildcards)


def all_table_extract_done(wildcards=filenames):
    return all_files(computed_file='table_extract.done', wildcards=wildcards)


def all_pngs_removed(wildcards=filenames):
    return all_files(computed_file='pngs.removed', wildcards=wildcards)


# Force to run OCR, tar and pdftotext.
rule all:
    input:
        ocr_txts=all_ocr_text_files(),
        pngs_removed=all_pngs_removed(),
        pdftotxts=all_pdftotext_files()
    run:
        for txt in input.pdftotxts:
            print(f"Ran OCR, tar and pdftotext for file: {txt}")

# Run pdftotext on all pdfs.
rule pdftotext_all:
    input:
        pdftotxts=all_pdftotext_files()
    run:
        for txt in input.pdftotxts:
            print(f"Executed pdftotext for file: {txt}")


# OCR all pdfs.
rule ocr_all:
    input:
        ocr_txts=all_ocr_text_files(),
        pngs_removed=all_pngs_removed()
    run:
        for txt in input.ocr_txts:
            print(f"Generated OCR text for file: {txt}")

# Run table-extract on all ocred files.
rule table_extract_all:
    input:
        all_table_extract_done(),
        pdftotxts=all_pdftotext_files(),
        pngs_removed=all_pngs_removed()
    run:
        print("Done with extracting tables")

# Copy pdf to the corresponding directory.
rule cp_pdf:
    input:
        pdf=INPUTDIR+"/{pdf_file}.pdf"
    output:
        pdf=OUTDIR+"/{pdf_file}/orig.pdf"
    shell:
        "cp {input.pdf} {output.pdf}"

# Apply pdftotext to the pdf.
rule pdf_to_text:
    input:
        pdf=OUTDIR+"/{pdf_file}/orig.pdf"
    output:
        txt=OUTDIR+"/{pdf_file}/pdftotext.txt"
    run:
        shell("pdftotext {input.pdf} - -enc UTF-8 > {output.txt}")

# Transform a page from a pdf to a png. This rule uses TMPDIR as output because pngs are large.
rule pdf_to_png_page:
    input:
        pdf=OUTDIR+"/{filename}/orig.pdf"
    output:
        png=TMPDIR+"/{filename}/png/page_{page_no}.png"
    wildcard_constraints:
        page_no="\d+"
    run:
        shell("scripts/pdf2png_page.sh {wildcards.page_no} {TMPDIR}/{wildcards.filename}/png {input.pdf}")


# OCR a page as a png. We output a hocr and txt file per page.
rule ocr_page:
    input:
        png=TMPDIR+"/{filename}/png/page_{page_no}.png"
    output:
        hocr=OUTDIR+"/{filename}/hocr/page_{page_no}.hocr",
        txt=OUTDIR+"/{filename}/ocr-txt/page_{page_no}.txt"
    wildcard_constraints:
        page_no="\d+"
    run:
        shell("scripts/ocr_page.sh {input.png} {output.hocr} {OUTDIR}/{wildcards.filename}")
        # FIXME Employ gnu parallel.

# TODO OCR all pages in parallel.

# Tar pngs and remove the pngs from tmpdir after the merging of the ocr_text.
rule tar_pngs:
    input:
        lambda wildcards: PDFArtefacts(f"{INPUTDIR}/{wildcards.filename}.pdf", TMPDIR).pngs(),
        ocr_txt=OUTDIR+"/{filename}/ocr_text.txt"
    output:
        tar_file=OUTDIR+"/{filename}/pngs.tar.gz"
    run:
        pngs=input[0:-1]
        shell("""
        tar -czf {output.tar_file} -C {TMPDIR}/{wildcards.filename} png
        """)

rule remove_pngs:
    input:
        lambda wildcards: PDFArtefacts(f"{INPUTDIR}/{wildcards.filename}.pdf", TMPDIR).pngs(),
        ocr_txt=OUTDIR+"/{filename}/ocr_text.txt"
    output:
        touch(OUTDIR+"/{filename}/pngs.removed")
    run:
        pngs=input[0:-1]
        shell("""
        rm {pngs} &&
        rmdir {TMPDIR}/{wildcards.filename}/png
        """)


# Enumerate all hocr files based from their information on how many pages this pdf has.
# Concatenate all pages as a ocr_text.txt
rule merge_ocr_txt:
    input:
        lambda wildcards: PDFArtefacts(f"{INPUTDIR}/{wildcards.filename}.pdf", OUTDIR).ocr_text()
    output:
        ocr_txt=OUTDIR+"/{filename}/ocr_text.txt"
    run:
        shell("cat {input} > {output.ocr_txt}")

# Run table-extract to output scores for each box in the hocr file.
rule table_extract:
    input:
        lambda wildcards: PDFArtefacts(f"{INPUTDIR}/{wildcards.filename}.pdf", OUTDIR).hocr(),
        pdftotext=OUTDIR+"/{filename}/pdftotext.txt"
    output:
        directory(OUTDIR+"/{filename}/hocr-ts"),
        touch(OUTDIR+"/{filename}/table_extract.done")
    run:
        config = TableExtractConfig(document_path=f"{OUTDIR}/{wildcards.filename}")
        config.is_extracting_tables = False
        config.is_writing_table_extract_boxes = False
        print("Start to run table-extract...")
        extract_tables(config)
        print("table-extract completed.")

# Wipe all (intermediate) output files.
rule clean:
    run:
        for tmp_dir in all_files("",outputdir=TMPDIR):
            shell("rm -rf {tmp_dir}")
        shell("rm -rf {OUTDIR}")

# Remove the pngs.tar.gz archives from OUTDIR. 
rule prune_archives:
    input:
        all_tars()
    run:
        shell("rm {input}")
