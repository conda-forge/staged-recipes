import os
import subprocess
import sys
from pathlib import Path
from textwrap import indent

from pytest import fixture, main

PKG = os.environ["PKG_NAME"].replace("vale-package-", "")
PYTEST_ARGS = ["-s", "-vv", "--color=yes", __file__]

STYLES = Path(os.environ["PREFIX"]) / "share/vale/styles"

VALE_ARGS = ["vale", "--output=JSON"]
VALE_INI = ".vale.ini"
LOCALES = ["au", "ca", "gb", "us", "za"]

VALE_INI_TEMPLATE = """
MinAlertLevel = suggestion
Packages = {name}-{locale}
[*]
BasedOnStyles = {name}-{locale}
"""


def test_correct_spelling(a_locale: str, tmp_path: Path):
    vale("test", "{}", locale=a_locale, tmp_path=tmp_path)


def test_not_correct_spelling(a_locale: str, tmp_path: Path):
    vale("mispellled", "Did you really mean", locale=a_locale, tmp_path=tmp_path)


@fixture(params=LOCALES)
def a_locale(request) -> str:
    return request.param


def vale(word: str, expected: str, locale: str, tmp_path: Path):
    config = tmp_path / VALE_INI
    config.write_text(VALE_INI_TEMPLATE.format(name=PKG, locale=locale.lower()))
    readme = tmp_path / "README.md"
    readme.write_text(word, encoding="utf-8")
    args = [*VALE_ARGS, readme.name]
    print(f"Checking if the output of `{args}` for `{word}` contains `{expected}`...")
    print(f"({tmp_path})", ">>>", *args)
    p = subprocess.Popen(
        args,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        cwd=str(tmp_path),
        encoding="utf-8",
    )
    out, err = p.communicate()
    print("... rc", p.returncode)
    print("... stdout")
    print(indent(f"{out}", "\t"))
    print("... stderr")
    print(indent(f"{err}", "\t"))
    assert expected in out


if __name__ == "__main__":
    sys.exit(main(PYTEST_ARGS))
