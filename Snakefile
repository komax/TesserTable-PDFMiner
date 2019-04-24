
OUTDIR = "ocr_output"

filenames = glob_wildcards("pdfs/{filename}.pdf")

def all_pdftotext_files(wildcards):
    return list(map(lambda p: f"{OUTDIR}/{p}/pdftotext.txt", wildcards.filename))


rule all:
    input:
        pdftotxts=all_pdftotext_files(filenames)
    run:
        for txt in input.pdftotxts:
            print(f"Used pdftotext for file: {txt}")

rule simple:
    run:
        print(filenames)
        number_pages_pdf("pdfs/Dominguez-Haydar_2011.pdf")

# rule mk_dir:
#     input:
#         pdf="pdfs/{pdf_file}.pdf"
#     output:
#         pdf_dir=directory("ocr_output/{pdf_file}")
#     shell:
#         "scripts/mkdir_for_pdf.sh {output.pdf_dir}"

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
    shell:
        "pdftotext {input.pdf} - -enc UTF-8 > {output.txt}"

# rule pdf_to_png:
#     input:
#         pdf="ocr_output/Dominguez-Haydar_2011/orig.pdf"
#     output:
#         png_dir=directory("ocr_output/Dominguez-Haydar_2011/png/")
#     run:
#         page_no=range(1, number_pages_pdf(input.pdf) + 1)
#         print(list(page_no))
#         shell("echo {output.png_dir}")


rule pages_to_png:
    input:
        pdf="ocr_output/{filename}/orig.pdf"
    output:
        pngs="ocr_output/{filename}/png/page_{page_no}.png"#,
        #png_dir=directory("ocr_output/{filename}/png/page_{page_no}.png")
    wildcard_constraints:
        page_no="\d+"
    run:
        #pages=shell("pdfinfo {input.pdf} | grep '^Pages:'")
        #for val in shell("pdfinfo {input.pdf} | grep '^Pages:'"):
        #    print(val)
        shell("scripts/pdf_to_png.sh ocr_output/{wildcards.filename}/png {input.pdf}")

rule ocr_page:
    input:
        png="ocr_output/{filename}/png/page_{page_no}.png"
    output:
        hocr="ocr_output/{filename}/hocr/page_{page_no}.hocr",
        txt="ocr_output/{filename}/ocr-txt/page_{page_no}.txt"
    wildcard_constraints:
        page_no="\d+"
    run:
        #shell("echo {input.png} {output.hocr}")
        shell("scripts/ocr_tesseract.sh {input.png} {output.hocr} ocr_output/{wildcards.filename}")
        # FIXME Employ gnu parallel.

# TODO OCR all pages in parallel.

rule merge_ocr_txt:
    input:
    # FIXME use pages_{page_no}.txt as input using a global wildcard.
        pdf="ocr_output/{filename}/orig.pdf"
    output:
        ocr_txt="ocr_output/{filename}/ocr_text.txt"
    run:
        pngs=expand("ocr_output/{filename}/ocr-txt/page_{page_no}.txt", page_no=range(1, number_pages_pdf(input.pdf) + 1), filename=wildcards.filename)
        shell("cat {pngs} > {output.ocr_txt}")
        print(input.pdf)
        print(pngs)
        print(output.ocr_txt)


rule table_extract:
    run:
        "table-extract.py"
        #FIXME Implement this.
