"""(re-)generate the spacy-models recipe"""
import jinja2
from subprocess import check_call
from pathlib import Path
import json
import fnmatch
import re

DEV_URL = "https://github.com/explosion/spacy-models"
VERSION = "3.3.0"
HEAD = "3d347dfd1755a004cf9b686edbffbfbec51515d8"

# TODO: current fails if building _everything_ at once, restore when smaller
# SIZE_PATTERN = "*"
SIZE_PATTERN = "*_sm"
SKIP_PATTERNS = [
    # needs sudachipy
    "ja_core*"
]
EXTRA_REQS = {
    # TODO: remove after https://github.com/conda-forge/spacy-pkuseg-feedstock/pull/11
    "spacy-pkuseg": ["cython"]
}

HERE = Path(__file__).parent
REPO = HERE.parent / "_spacy_models_repo"
TMPL = HERE / "meta.yaml.j2"
META = HERE / "meta.yaml"


def reqtify(raw):
    """split requirements on operators"""
    if "=" in raw:
        return " ".join(re.findall(r"(.*?)([><=!~\^].*)", raw)[0])
    return raw


def ensure_repo():
    """ensure that the repo is up-to-date"""
    if not REPO.exists():
        check_call(["git", "clone", DEV_URL, str(REPO)])
        check_call(["git", "fetch"], cwd=str(REPO))
        check_call(["git", "checkout", HEAD], cwd=str(REPO))


def update_recipe():
    all_metas = {
        p: json.load(p.open())
        for p in sorted((REPO / "meta").glob(f"{SIZE_PATTERN}-{VERSION}.json"))
        if not any([fnmatch.fnmatch(p.name, pattern) for pattern in SKIP_PATTERNS])
    }

    for path, meta in all_metas.items():
        for pattern, extra_reqs in EXTRA_REQS.items():
            if any(pattern in req for req in meta["requirements"]):
                print(f"""- {path.name} needs extra: {", ".join(extra_reqs)}""")
                meta["requirements"] += extra_reqs
        meta["requirements"] = sorted(set(meta["requirements"]))

    template = jinja2.Template(
        TMPL.read_text(encoding="utf-8").strip(),
        # use alternate template delimiters to avoid conflicts
        block_start_string="<%",
        block_end_string="%>",
        variable_start_string="<<",
        variable_end_string=">>",
    )

    context = dict(
        all_metas=all_metas, reqtify=reqtify, version=VERSION, dev_url=DEV_URL
    )

    META.write_text(template.render(**context).strip() + "\n", encoding="utf-8")


def lint_recipe():
    check_call(["conda-smithy", "recipe-lint", str(HERE)])


if __name__ == "__main__":
    ensure_repo()
    update_recipe()
    lint_recipe()
