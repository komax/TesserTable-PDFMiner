from pathlib import Path

from snakemake import shell


def number_pages_pdf(pdf_file):
    result_bytes = shell("pdfinfo {pdf_file} | grep '^Pages:' -a | sed 's/[^0-9]*//'", read=True)
    result_str = result_bytes.decode("utf-8")
    return int(result_str)


class PDFArtefacts(object):
    def __init__(self, pdf_path, out_dir):
        self.pdf_path = Path(pdf_path)
        self.out_dir = Path(out_dir)
        self.pages_pdf = number_pages_pdf(pdf_path)

    def pages_range(self):
        return range(1, self.pages_pdf + 1)

    def filename(self):
        return self.pdf_path.stem

    def _file_list(self, subdir, ext, wildcard_pattern="{filename}"):
        result = []
        for page_no in self.pages_range():
            png_path = self.out_dir / wildcard_pattern / f"{subdir}/page_{page_no}.{ext}"
            result.append(str(png_path))
        return result

    def pngs(self, wildcard="{filename}"):
        return self._file_list(subdir="png", ext="png", wildcard_pattern=wildcard)

    def hocr(self, wildcard="{filename}"):
        return self._file_list(subdir="hocr", ext="hocr", wildcard_pattern=wildcard)

    def hocr_table_extract(self):
        return self._file_list(subdir="hocr-ts", ext="hocr", wildcard_pattern=self.filename())
    
    def ocr_text(self, wildcard="{filename}"):
        return self._file_list(subdir="ocr-txt", ext="txt", wildcard_pattern=wildcard)

def main():
    pdf_artefacts = PDFArtefacts('Laurance_-_1994_-_Rainforest_fragmentation_and_the_structure_of_small_mammal_communities_in_tropical_Queensland', 'ocr_output')
    print(pdf_artefacts.pages_pdf)
    print(pdf_artefacts.pngs())
    print(pdf_artefacts.hocr())
    print(pdf_artefacts.ocr_text())

if __name__ == "__main__":
    main()
