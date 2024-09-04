"""Test converters for conda-forge packages supported by sphinxcontrib-svg2pdfconverter."""

import pytest

from pathlib import Path
from subprocess import call
import shutil
import sys
import os

# `inkscape` is not generally available or maintined on conda-forge, but worth
# trying if available.
INKSCAPE = os.environ.get("NO_INKSCAPE") is not None and (
    shutil.which("inkscape") or shutil.which("inkscape.exe")
)
CONVERTERS = [
    "cairosvgconverter",
    "rsvgconverter",
    *(["inkscapeconverter"] if INKSCAPE else []),
]
TEST_ARGS = [
    "coverage",
    "run",
    "--branch",
    "--include",
    "*/sphinxcontrib/*converter.py",
    "-m",
    "pytest",
    "-vv",
    "--tb=long",
    "--color=yes",
    "converter_test.py",
]
REPORT_ARGS = [
    "coverage",
    "report",
    "--show-missing",
    "--skip-covered",
    "--fail-under=41",
]
HERE = Path(__file__).parent
TECTONIC_CACHE_DIR = HERE / ".tectonic"

FILES: dict[str, str] = {}

# most basic sphinx configuration
FILES["conf.py"] = """# an example conf.py
extensions = ["sphinxcontrib.CONVERTER"]
copyright = "2024"
version = "0"
release = "0.0.0"
master_doc = "index"
project = "test"
author = "test"
language = "en"
latex_documents = [(master_doc, "test.tex", project, author, "manual")]
"""

# an example file with multiple svg
FILES["index.rst"] = """
This is a heading
=================

There should be an image below this:

.. image:: example.svg

There should be an image above and below this.

.. image:: example-copy.svg

There should be an image above this.

"""

# simple svg
FILES["example.svg"] = """<?xml version="1.0" encoding="utf-8" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="200" height="200">
  <rect width="200" height="200" rx="10" fill="red"/>
  <text x="20" y="20">CONVERTER</text>
</svg>
"""

# another copy of the svg
FILES["example-copy.svg"] = FILES["example.svg"]

ENV = {TECTONIC_CACHE_DIR: str(TECTONIC_CACHE_DIR), **os.environ}


@pytest.fixture(params=CONVERTERS)
def a_project(request, tmp_path: Path) -> Path:
    src = tmp_path / "src"
    for filename, content in FILES.items():
        dest = src / filename
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(content.replace("CONVERTER", request.param), encoding="utf-8")
    return src


def test_convert(a_project: Path, script_runner):
    sphinx_args = ["sphinx-build", "-W", "-j2", "-b", "latex", "src", "build"]
    cwd = a_project.parent
    res = script_runner.run(sphinx_args, cwd=str(cwd))
    assert res.returncode == 0
    build = cwd / "build"
    pdf = build / "test.pdf"
    rc = call(["tectonic", "-X", "compile", "test.tex"], cwd=str(build), env=ENV)
    assert rc == 0
    assert pdf.exists()


if __name__ == "__main__":
    print(">>>", *TEST_ARGS, flush=True)
    sys.exit(call(TEST_ARGS) or call(REPORT_ARGS))
