import os
import tomli
import re
from pathlib import Path
from ruamel.yaml import YAML
from packaging.requirements import Requirement

import sys

yaml = YAML(typ="safe")

UTF8 = dict(encoding="utf-8")
PKG_PREFIX = "morph-kgc-with-"
SRC_DIR = Path(os.environ["SRC_DIR"])
RECIPE_DIR = Path(os.environ["RECIPE_DIR"])

PPT = SRC_DIR / "pyproject.toml"
META_YAML = RECIPE_DIR / "meta.yaml"

PPT_DATA = tomli.loads(PPT.read_text(**UTF8))
PPT_EXTRAS = PPT_DATA["project"]["optional-dependencies"]
META_RAW = META_YAML.read_text(**UTF8).replace(
    "- {{ pin",
    "# - {{ pin",
)
META_DATA = yaml.load("outputs:" + META_RAW.split("outputs:")[1])
OUTPUTS = {
    output["name"].replace(PKG_PREFIX, ""): output for output in META_DATA["outputs"]
}
SKIP_EXTRAS = {
    "all": "custom package",
    "kuzu": "missing depedencies",
    "neo4j": "missing depedencies",
    "test": "custom package",
}

PYPI_CONDA_MAP = {r"psycopg\[binary\]": "psycopg"}


def to_conda(raw):
    for pattern, repl in PYPI_CONDA_MAP.items():
        raw = re.sub(pattern, repl, raw)
    return raw


def check_deps(extra, ppt_deps) -> int:
    print("... checking", f"{PKG_PREFIX}{extra}", flush=True)
    if extra in SKIP_EXTRAS:
        print(" ... ", extra, "is skipped because", SKIP_EXTRAS[extra])
        return 0
    output = OUTPUTS[extra]
    my_deps = sorted(output["requirements"]["run"])
    print(
        f"""
        ... pyproject.toml#/project/optional/dependencies
        { sorted(ppt_deps) }
        ... meta.yaml#/outputs[@name="{PKG_PREFIX}"]/dependencies/run
        { sorted(my_deps) }
    """
    )
    ppt_reqs = {Requirement(to_conda(d)) for d in ppt_deps}
    my_reqs = {Requirement(d) for d in my_deps}
    missing = ppt_reqs - my_reqs
    extra = my_reqs - ppt_reqs

    if missing or extra:
        print("missing", missing)
        if missing:
            print("!!! MISSING", missing)

        print("missing", extra)
        if extra:
            print("!!! EXTRA", extra)

        sys.exit(len(missing) + len(extra))

    return 0


def main() -> int:
    [check_deps(extra, deps) for extra, deps in PPT_EXTRAS.items()]
    return 0


if __name__ == "__main__":
    sys.exit(main())
