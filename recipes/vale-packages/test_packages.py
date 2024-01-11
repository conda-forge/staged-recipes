import os
import pytest
import sys
from pathlib import Path
from subprocess import Popen, PIPE
import json

UTF8 = dict(encoding="utf-8")
SRC_DIR = Path(os.environ["SRC_DIR"])

LIBRARY_JSON = SRC_DIR / "library.json"
VALE_PATH = Path(sys.prefix) / "share/vale/styles"

INI_TEMPLATE = """
MinAlertLevel = suggestion
Packages = {name}

[*]
BasedOnStyles = Vale, {name}
"""

MD_TEMPLATE = """
##  Bad header

- misssplt word

this, that adn the other thing
"""

LIBRARY = [
    pkg["name"]
    for pkg in json.loads(LIBRARY_JSON.read_text(**UTF8))
    if (VALE_PATH / pkg["name"]).exists()
]


@pytest.fixture(params=sorted(LIBRARY))
def a_vale_ini(request, tmp_path: Path):
    vale_ini = tmp_path / ".vale.ini"
    vale_ini.write_text(INI_TEMPLATE.format(name=request.param), **UTF8)
    return a_vale_ini


@pytest.fixture
def an_md(tmp_path: Path):
    readme = tmp_path / "README.md"
    readme.write_text(MD_TEMPLATE, **UTF8)
    return readme


def test_style(a_vale_ini: Path, an_md: Path):
    vale_args = ["vale", "--output=JSON", an_md]
    proc = Popen(
        vale_args, stdout=PIPE, stderr=PIPE, cwd=str(a_vale_ini.parent), **UTF8
    )
    stdout, stderr = proc.communicate()
    observed = json.loads(stdout)
    assert observed == {}
