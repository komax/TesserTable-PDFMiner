

rule mk_dir:
    input:
        pdf="pdfs/{pdf_file}.pdf"
    output:
        pdf_dir="ocr_output/{pdf_file}"
    script:
        "foo.sh"

rule pages_to_png:
    script:
        "foo.sh"

rule pdf_to_text:
    shell:
        "pdftotext"

rule ocr_tesseract:
    script:
        "ocr_script.sh"
        # Employ gnu parallel.

rule table_extract:
    run:
        "table-extract.py"
