import os
import tempfile

from rpptx import Presentation
from rpptx.util import Inches

prs = Presentation()
slide = prs.slides.add_slide(prs.slide_layouts[6])
box = slide.shapes.add_textbox(Inches(1), Inches(1), Inches(8), Inches(1))
box.text = "Hello from conda-forge"

with tempfile.TemporaryDirectory() as tmp:
    path = os.path.join(tmp, "hello.pptx")
    prs.save(path)
    reopened = Presentation(path)

texts = [shape.text for shape in reopened.slides[0].shapes if shape.has_text_frame]
assert "Hello from conda-forge" in texts
assert reopened.to_pdf().startswith(b"%PDF")
