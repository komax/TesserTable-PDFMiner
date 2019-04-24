import glob

class TableExtractConfig(object):
    def __init__(self, document_path):
        self.document_path = document_path
        self.subdir_hocr = "hocr"
        self.subdir_hocr_ts = "hocr-ts"
        self.hocr_ext = "hocr"
        
        self.text_layer_filename = "pdftotext.txt"

        self.is_extracting_tables = False
        self.subdir_extracted_tables = "tables"
        self.extracted_tables_ext = "png"

        self.is_writing_table_extract_boxes = False
        self.subdir_table_extract_boxes = "table-detection"

    def hocr_files(self):
        return glob.glob(f"{self.document_path}/{self.subdir_hocr}/*.{self.hocr_ext}")

    def text_layer_path(self):
        return f"{self.document_path}/{self.text_layer_filename}"
