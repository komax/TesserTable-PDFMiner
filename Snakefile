
rule mk_dir:
    input:
        pdf="pdfs/{pdf_file}.pdf"
    output:
        pdf_dir=directory("ocr_output/{pdf_file}")
    shell:
        "scripts/mkdir_for_pdf.sh {output.pdf_dir}"

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
