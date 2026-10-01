from rdocx import Document

doc = Document()
doc.add_paragraph("Hello from conda-forge")

reopened = Document.from_bytes(doc.to_bytes())
assert "Hello from conda-forge" in [p.text for p in reopened.paragraphs]
assert reopened.to_pdf().startswith(b"%PDF")
