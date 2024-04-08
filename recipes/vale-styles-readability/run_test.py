import json
import os
import sys
from pathlib import Path
from subprocess import Popen, PIPE, call
from textwrap import indent
from typing import Generator

os.environ.update(
    PYTHONIOENCODING="utf-8",
    PYTHONLEGACYWINDOWSFSENCODING="utf-8",
)

from pytest import fixture

UTF8 = dict(encoding="utf-8")
VALE_NAME = "Readability"

VALE_PATH = Path(sys.prefix) / "share/vale/styles"
VALE_CONF_PATH = VALE_PATH / ".vale-config"
VALE_INI = ".vale.ini"
PYTEST_ARGS = ["-svv", "--color=yes", __file__]

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

def test_vale_path():
    rc, stdout, stderr = _run_vale_json("ls-dirs")
    assert str(VALE_PATH) in stdout, f"`{VALE_PATH}` was not found"


def test_style_in_vale_path(a_markdown_file_with_issue: Path):
    ini = a_markdown_file_with_issue.parent / VALE_INI
    name = ini.parent.name
    style_dir = VALE_PATH / name
    assert style_dir.is_dir(), f"`{name}` is not in {VALE_PATH}"


def test_style_finds_or_fixes_issue(a_markdown_file_with_issue: Path):
    ini = a_markdown_file_with_issue.parent / VALE_INI
    name = ini.parent.name

    rc, stdout, stderr = _run_vale_json(a_markdown_file_with_issue.name)

    assert not stderr, f"`{name}` didn't expect any stderr"

    issues = json.loads(stdout)

    assert issues

    ini.write_text(DEFAULT_INI, **UTF8)

    rc2, stdout2, stderr2 = _run_vale_json(a_markdown_file_with_issue.name)
    issues2 = json.loads(stdout2)

    assert not stderr2, f"didn't expect any stderr without `{name}`"

    assert not issues2


@fixture
def in_a_project(tmp_path: Path) -> Generator[Path, None, None]:
    project = tmp_path / VALE_NAME
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
    print(indent(ini.read_text(**UTF8), "\t"))
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
    print(">>>", *args)
    proc = Popen(args, stdout=PIPE, stderr=PIPE, **UTF8)
    stdout, stderr = proc.communicate()
    print("... rc", proc.returncode)
    print("... stdout")
    print(indent(stdout, "\t"))
    print("... stderr")
    print(indent(stderr, "\t"))
    return proc.returncode, stdout, stderr


if __name__ == "__main__":
    sys.exit(call([sys.executable, "-m", "pytest", *PYTEST_ARGS, __file__], **UTF8))
