import glob
from pathlib import Path

class TableExtractConfig(object):
    def __init__(self, document_path):
        self.document_path = document_path
        self.subdir_hocr = "hocr"
        self.subdir_hocr_ts = "hocr-ts"
        self.hocr_ext = "hocr"
        
        self.text_layer_filename = "pdftotext.txt"

        self.is_extracting_tables = True
        self.subdir_extracted_tables = "tables"
        self.extracted_tables_ext = "png"

        self.is_writing_table_extract_boxes = True
        self.subdir_table_extract_boxes = "table-detection"

    def make_subdirs(self):
        out_path = Path(self.document_path)
        hocr_ts_path = out_path / self.subdir_hocr_ts
        hocr_ts_path.mkdir(parents=True, exist_ok=True)

        if self.is_extracting_tables:
            extracted_tables_subdir = out_path / self.subdir_extracted_tables
            extracted_tables_subdir.mkdir(parents=True, exist_ok=True)

        if self.is_writing_table_extract_boxes:
            table_extract_annotation_subdir = out_path / self.subdir_table_extract_boxes
            table_extract_annotation_subdir.mkdir(parents=True, exist_ok=True)

    def hocr_files(self):
        return glob.glob(f"{self.document_path}/{self.subdir_hocr}/*.{self.hocr_ext}")

    def text_layer_path(self):
        return f"{self.document_path}/{self.text_layer_filename}"
