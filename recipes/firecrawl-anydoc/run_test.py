from pathlib import Path
from tempfile import TemporaryDirectory

import anydoc

csv = b"name,value\nalpha,42\n"
markdown = anydoc.to_markdown_bytes(csv, format="csv")
assert "alpha" in markdown and "42" in markdown, markdown
with TemporaryDirectory() as directory:
    path = Path(directory) / "sample.csv"
    path.write_bytes(csv)
    assert anydoc.to_markdown(path) == markdown
rtf = br"{\rtf1\ansi Hello from conda-forge.}"
assert "Hello from conda-forge." in anydoc.to_markdown_bytes(rtf)
