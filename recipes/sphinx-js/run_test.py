from os.path import join, dirname
from subprocess import check_call
import json
import re
import shutil
import tempfile

try:
    which = shutil.which
except ImportError:
    from backports.shutil_which import which

NPM = which("npm")
HERE = dirname(__file__)
TESTS = join(HERE, "src", "tests")

# TODO: hoist these to the recipe
PKG = {
  "devDependencies": {
    "jsdoc": "3.6.3",
    "typedoc": "0.15.0"
  },
  "scripts": {
    "test": "python -m pytest -vv"
  }
}


def test_in_tmp(tmp):
    print("- creating package.json to ensure js/tsdoc are installed/on path...")
    with open(join(tmp, "package.json"), "w+", encoding="utf-8") as fp:
        json.dump(PKG, fp)

    print("- installing npm packages...")
    check_call([NPM, "install"], cwd=tmp)

    print("- copying tests...")
    shutil.copytree(TESTS, join(tmp, "tests"))

    print("- running pytest inside npm...")
    check_call([NPM, "run", "test"], cwd=tmp)


if __name__ == "__main__":
    print("- creating tmp directory...")
    TMP = tempfile.mkdtemp()

    try:
        print("- ensuring no parent paths of tests start with _")
        assert not re.findall("[\\/]_", TMP), \
            "!!! path probably contains a child with an underscore: {}".format(TMP)
        test_in_tmp(TMP)
        print("SUCCESS")
    finally:
        print("cleaning tmp directory")
        shutil.rmtree(TMP)
