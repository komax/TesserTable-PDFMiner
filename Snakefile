from pathlib import Path

OUTDIR = "output"


def all_pdfs(dir='pdfs'):
    ext = "pdf"
    pdf_paths = sorted(Path(dir).glob('*.{}'.format(ext)))
    return list(map(str, pdf_paths))


def tr_pdf_to_out_dir(pdf_input, out_dir="ocr_output"):
    file_path = Path(pdf_input)
    return Path(out_dir) / file_path.stem


def all_pdftotext_files(paths):
    return list(map(lambda path: str(tr_pdf_to_out_dir(path) / "pdftotext.txt"), paths))


def number_pages_pdf(pdf_file):
    result_bytes = shell("pdfinfo {pdf_file} | grep '^Pages:' | sed 's/[^0-9]*//'", read=True)
    result_str = result_bytes.decode("utf-8")
    return int(result_str)

rule all:
    input:
        pdftotxts=all_pdftotext_files(all_pdfs())
    run:
        print(input.pdftotxts)

rule simple:
    run:
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

rule pdf_to_png:
    input:
        pdf="ocr_output/{filename}/orig.pdf"
    output:
        png_dir=directory("ocr_output/{filename}/png/")
    run:
        page_no=range(1, number_pages_pdf(input.pdf))
        print(list(page_no))
        shell("echo {output.pngs}")


# rule pages_to_png:
#     input:
#         pdf="ocr_output/{filename}/orig.pdf"
#     output:
#         pngs="ocr_output/{filename}/png/page_{page_no}.png"#,
#         #png_dir=directory("ocr_output/{filename}/png/page_{page_no}.png")
#     wildcard_constraints:
#         page_no="\d+"
#     run:
#         #pages=shell("pdfinfo {input.pdf} | grep '^Pages:'")
#         #for val in shell("pdfinfo {input.pdf} | grep '^Pages:'"):
#         #    print(val)
#         shell("scripts/pdf_to_png.sh ocr_output/{wildcards.filename}/png {input.pdf}")

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
        # Employ gnu parallel.

rule merge_ocr_txt:
    input:


rule table_extract:
    run:
        "table-extract.py"
