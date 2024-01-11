"""(re-)generate the vale-styles multi-output recipe based on the tarball

Invoke this locally from the root of the feedstock, assuming `jinja2`:

    python recipe/update_recipe.py
    git commit -m "updated recipe with update script"
    conda smithy rerender

The optional `--check` parameter will fail if new styless are added, or
dependencies change.

This tries to work with the conda-forge autotick bot by reading updates from
`meta.yml`:

- build_number
- version
- sha256sum

If running locally against a non-bot-requested version, you'll probably need
to update those fields in `meta.yaml`.

If some underlying project data changed e.g. the `path_to-the_tarball`, update
`meta.j2.yaml` and re-run.
"""
import os
import re
import sys
import tempfile
import json
import tarfile
from pathlib import Path
from urllib.request import urlretrieve
import difflib

import jinja2

DELIMIT = dict(
    # use alternate template delimiters to avoid conflicts
    block_start_string="<%",
    block_end_string="%>",
    variable_start_string="<<",
    variable_end_string=">>",
)
DEV_URL = "https://github.com/errata-ai/packages"

#: assume running locally
HERE = Path(__file__).parent
WORK_DIR = HERE
SRC_DIR = Path(os.environ["SRC_DIR"]) if "SRC_DIR" in os.environ else None

#: assume inside conda-build
if "RECIPE_DIR" in os.environ:
    WORK_DIR = Path(os.environ["RECIPE_DIR"])

TMPL = [*WORK_DIR.glob("*.j2.*")]
META = WORK_DIR / "meta.yaml"
CURRENT_META_TEXT = META.read_text(encoding="utf-8")

#: read the version from what the bot might have updated
try:
    VERSION = re.findall(r'set version = "([^"]*)"', CURRENT_META_TEXT)[0].strip()
    SHA256_SUM = re.findall(r"sha256: ([\S]*)", CURRENT_META_TEXT)[0].strip()
    BUILD_NUMBER = re.findall(r"number: ([\S]*)", CURRENT_META_TEXT)[0].strip()
except Exception as err:
    print(CURRENT_META_TEXT)
    print(f"failed to find version info in above {META}")
    print(err)
    sys.exit(1)

#: instead of cloning the whole repo, just download tarball
TARBALL_URL = f"{DEV_URL}/archive/refs/tags/v{VERSION}.tar.gz"


def preflight_recipe():
    """check the recipe first"""
    print("version:", VERSION)
    print("sha256: ", SHA256_SUM)
    print("number: ", BUILD_NUMBER)
    assert VERSION, "no meta.yaml#/package/version detected"
    assert SHA256_SUM, "no meta.yaml#/source/sha256 detected"
    assert BUILD_NUMBER, "no meta.yaml#/build/number detected"
    print("information from the recipe looks good!", flush=True)


def read_release_context(path: Path):
    outputs = {}
    lib_path = path / "library.json"

    if not lib_path.exists():
        print("\n".join(p.name for p in path.glob("*")))
        print(f"!!! {lib_path} not found")
        sys.exit(1)

    libs = sorted(
        json.loads(lib_path.read_text(encoding="utf-8")),
        key=lambda lib: lib["name"].lower(),
    )

    for lib in libs:
        name = lib["name"]
        lib_path = path / "pkg" / name
        if not lib_path.exists():
            print(f"... skipping {name} (not in repo)...")
            continue

        print(f"... found {name}")
        output = outputs[name] = lib

        pkg_meta = lib_path / name / "meta.json"

        if pkg_meta.exists():
            print("   ... found meta.json")
            output["meta"] = json.loads(pkg_meta.read_text(encoding="utf-8"))

    assert outputs, "Didn't find any outputs"
    return dict(outputs=outputs)


def get_release_context():
    """fetch the pyproject.toml data"""
    if SRC_DIR and (SRC_DIR / "LICENSE").exists():
        print(f"... using repo from {SRC_DIR}...")
        return read_release_context(SRC_DIR)

    print(f"... fetching from {TARBALL_URL}...")
    with tempfile.TemporaryDirectory() as td:
        tdp = Path(td)
        tarpath = tdp / Path(TARBALL_URL).name
        urlretrieve(TARBALL_URL, tarpath)

        with tarfile.open(tarpath, "r:gz") as tf:
            tf.extractall(tdp / "src")
            return read_release_context(tdp / "src" / f"packages-{VERSION}")


def update_recipe(check=False):
    """update or check a recipe based on the `pyproject.toml` data"""
    preflight_recipe()

    context = dict(
        version=VERSION,
        build_number=BUILD_NUMBER,
        sha256_sum=SHA256_SUM,
        **get_release_context(),
    )

    for tmpl_path in TMPL:
        dest_path = tmpl_path.parent / tmpl_path.name.replace(".j2", "")
        old_text = dest_path.read_text(encoding="utf-8")
        template = jinja2.Template(
            tmpl_path.read_text(encoding="utf-8").strip(), **DELIMIT
        )
        new_text = template.render(**context).strip() + "\n"

        if check:
            if new_text.strip() != old_text.strip():
                print(f"{dest_path} is not up-to-date:")
                print(
                    "\n".join(
                        difflib.unified_diff(
                            old_text.splitlines(),
                            new_text.splitlines(),
                            dest_path.name,
                            f"{dest_path.name} (updated)",
                        )
                    )
                )
                print("either apply the above patch, or run locally:")
                print("\n\tpython recipe/update_recipe.py\n")
                return 1
        else:
            dest_path.write_text(new_text, encoding="utf-8")

    return 0


if __name__ == "__main__":
    sys.exit(update_recipe(check="--check" in sys.argv))
