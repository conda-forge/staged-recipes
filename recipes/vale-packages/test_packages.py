import json
import os
import sys
from pathlib import Path
from subprocess import Popen, PIPE
from textwrap import indent
from typing import Generator

from pytest import fixture, main

UTF8 = dict(encoding="utf-8")
SRC_DIR = Path(os.environ["SRC_DIR"])

LIBRARY_JSON = SRC_DIR / "library.json"
VALE_PATH = Path(sys.prefix) / "share/vale/styles"
VALE_INI = ".vale.ini"
PYTEST_ARGS = [
    "-svv",
    "--color=yes",
    "--tb=long",
    __file__,
]

PACKAGE_FIXES_ISSUE = ["Hugo"]

LIBRARY = sorted(
    pkg["name"]
    for pkg in json.loads(LIBRARY_JSON.read_text(**UTF8))
    if (VALE_PATH / pkg["name"]).exists() and pkg["name"]
)

DEFAULT_INI = """
MinAlertLevel = suggestion

[*]
BasedOnStyles = Vale
"""

INI_TEMPLATE = """
MinAlertLevel = suggestion
Packages = {name}

[*]
BasedOnStyles = {name}
"""

DEFAULT_MD_WITH_AN_ISSUE = """
# hello world
"""

MD_WITH_AN_ISSUE = {}

MD_WITH_AN_ISSUE["Joblint"] = """
# crush it bro
"""

MD_WITH_AN_ISSUE["write-good"] = """
a chip off the old block
"""

MD_WITH_AN_ISSUE["Readability"] = (
    " ".join(["Buffalo", *[["chicken", "buffalo"][i % 2] for i in range(200)]]) + "."
)

MD_WITH_AN_ISSUE["alex"] = """
ancient man
"""

MD_WITH_AN_ISSUE["proselint"] = """
taking off momentarily
"""

MD_WITH_AN_ISSUE["Hugo"] = """
{{<  myshortcode `This is some <b>HTML</b>, ... >}}
"""


def test_vale_path():
    rc, stdout, stderr = _run_vale_json("ls-dirs")
    assert str(VALE_PATH) in stdout


def test_style_finds_or_fixes_issue(a_markdown_file_with_issue: Path):
    ini = a_markdown_file_with_issue.parent / VALE_INI
    name = ini.parent.name
    should_fix = name in PACKAGE_FIXES_ISSUE

    rc, stdout, stderr = _run_vale_json(a_markdown_file_with_issue.name)
    issues = json.loads(stdout)

    assert not stderr, f"{name} didn't expect any stderr"

    if should_fix:
        assert not issues
    else:
        assert issues

    ini.write_text(DEFAULT_INI, **UTF8)

    rc2, stdout2, stderr2 = _run_vale_json(a_markdown_file_with_issue.name)
    issues2 = json.loads(stdout2)

    assert not stderr2, f"didn't expect any stderr without {name}"

    if should_fix:
        assert issues2
    else:
        assert not issues2


@fixture(params=LIBRARY)
def a_vale_package(request) -> str:
    return request.param


@fixture
def in_a_project(a_vale_package: str, tmp_path: Path) -> Generator[Path, None, None]:
    project = tmp_path / a_vale_package
    project.mkdir()
    old_cwd = Path.cwd()
    os.chdir(str(project))
    yield project
    os.chdir(old_cwd)


@fixture
def a_vale_ini(in_a_project: Path) -> Path:
    name = in_a_project.name
    ini = in_a_project / VALE_INI
    ini.write_text(INI_TEMPLATE.format(name=name), **UTF8)
    print(name, "config")
    print(indent(ini.read_text(), "\t"))
    return ini


@fixture
def a_markdown_file_with_issue(a_vale_ini: Path) -> Path:
    project = a_vale_ini.parent
    name = project.name
    readme = project / "README.md"
    readme.write_text(MD_WITH_AN_ISSUE.get(name, DEFAULT_MD_WITH_AN_ISSUE), **UTF8)
    return readme


def _run_vale_json(*args: str):
    args = ["vale", "--output=JSON", *args]
    proc = Popen(args, stdout=PIPE, stderr=PIPE, **UTF8)
    stdout, stderr = proc.communicate()
    print("... rc", proc.returncode)
    print("... stdout")
    print(indent(stdout, "\t"))
    print("... stderr")
    print(indent(stderr, "\t"))
    return proc.returncode, stdout, stderr


if __name__ == "__main__":
    sys.exit(main(PYTEST_ARGS))
