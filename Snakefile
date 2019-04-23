

rule mk_dir:
    input:
        pdf="pdfs/{pdf_file}.pdf"
    output:
        pdf_dir=directory("ocr_output/{pdf_file}")
    shell:
        "scripts/mkdir_for_pdf.sh {output.pdf_dir}"

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
        hocr="ocr_output/{filename}/hocr/page_{page_no}.hocr"
    wildcard_constraints:
        page_no="\d+"
    run:
        #shell("echo {input.png} {output.hocr}")
        shell("scripts/ocr_tesseract.sh {input.png} {output.hocr}")
        # Employ gnu parallel.


rule table_extract:
    run:
        "table-extract.py"
