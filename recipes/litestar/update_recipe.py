"""(re-)generate the litestar multi-output recipe based on `pyproject.toml`

Invoke this locally from the root of the feedstock, assuming `tomli`, `jinja2`, and `packaging`:

    python recipe/update_recipe.py
    git commit -m "updated recipe with update script"
    conda smithy rerender

The optional `--check` parameter will fail if new `[extra]`s are added, or
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
import tarfile
from pathlib import Path
from urllib.request import urlretrieve
import difflib

import jinja2
import tomli
from packaging.requirements import Requirement

DELIMIT = dict(
    # use alternate template delimiters to avoid conflicts
    block_start_string="<%",
    block_end_string="%>",
    variable_start_string="<<",
    variable_end_string=">>",
)
DEV_URL = "https://github.com/litestar-org/litestar"

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
MIN_PYTHON = ">=3.8"

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

#: the path to `pyproject.toml` in the tarball
#: at present, this is the only place where the name change has an impact,
#: but will soon be pervasive on the 2.0.x line
PYPROJECT_TOML = f"litestar-{VERSION}/pyproject.toml"

#: despite claiming optional, these end up as hard `Requires-Dist`
KNOWN_REQS = [
    "mako",
]

#: these are handled externally
KNOWN_SKIP = [
    "python",
]

#: handle conda-forge/PyPI/hyphen/underscore insensitivity
TRANFORM_DEP = {
    "prometheus-client": "prometheus_client",
    "pydantic-factories": "pydantic_factories",
    "redis": "redis-py",
    "typing-extensions": "typing_extensions",
}

#: handle lack of conda support for [extras]
TRANSFORM_EXTRA_DEP = {
    ("uvicorn", ("standard",)): "uvicorn-standard",
    # https://github.com/redis/redis-py/blob/v4.5.3/setup.py#L57
    ("redis-py", ("hiredis",)): "hi-redis",
}

#: handle transient extras incurred, keyed by post-transform names
EXTRA_EXTRA_DEPS = {}

#: a meaningful import that isn't caught
EXTRA_TEST_IMPORTS = {
    "attrs": "litestar.contrib.attrs",
    "cli": "litestar.cli.main",
    "cryptography": "litestar.middleware.session.client_side",
    "jinja": "litestar.contrib.jinja",
    "jwt": "litestar.contrib.jwt.jwt_token",
    "mako": "litestar.contrib.mako",
    "minijinja": "litestar.contrib.minijinja",
    "opentelemetry": "litestar.contrib.opentelemetry",
    "piccolo": "litestar.contrib.piccolo",
    "picologging": "litestar.logging.picologging",
    "prometheus": "litestar.contrib.prometheus",
    "pydantic": "litestar.contrib.pydantic",
    "redis": "litestar.cache.redis_cache_backend",
    "sqlalchemy": "litestar.plugins.sqlalchemy",
    "structlog": "litestar.middleware.logging",
}

#: commands to run after `pip check`
EXTRA_TEST_COMMANDS = {
    "cli": "litestar --help",
}

#: some extras may become temporarily broken: add them here to skip
SKIP_EXTRAS = [
    # re-built manually
    "full",
    # several levels of missing deps
    "piccolo",
    "pydantic",
]


def reqtify(raw):
    """split dependency into conda requirement"""
    req = Requirement(raw)
    name = req.name
    dep = str(req.specifier)
    name = TRANFORM_DEP.get(name, name).lower()
    if req.extras:
        name = TRANSFORM_EXTRA_DEP[(name, tuple(sorted(req.extras)))]
    return f"{name} {dep}".strip()


def preflight_recipe():
    """check the recipe first"""
    print("version:", VERSION)
    print("sha256: ", SHA256_SUM)
    print("number: ", BUILD_NUMBER)
    assert VERSION, "no meta.yaml#/package/version detected"
    assert SHA256_SUM, "no meta.yaml#/source/sha256 detected"
    assert BUILD_NUMBER, "no meta.yaml#/build/number detected"
    print("information from the recipe looks good!", flush=True)


def get_pyproject_data():
    """fetch the pyproject.toml data"""
    if SRC_DIR:
        print(f"reading pyprojec.toml from {TARBALL_URL}...")
        return tomli.loads((SRC_DIR / "pyproject.toml").read_text(encoding="utf-8"))

    print(f"reading pyproject.toml from {TARBALL_URL}...")
    with tempfile.TemporaryDirectory() as td:
        tdp = Path(td)
        tarpath = tdp / Path(TARBALL_URL).name
        urlretrieve(TARBALL_URL, tarpath)
        with tarfile.open(tarpath, "r:gz") as tf:
            return tomli.load(tf.extractfile(PYPROJECT_TOML))


def update_recipe(check=False):
    """update or check a recipe based on the `pyproject.toml` data"""
    preflight_recipe()
    pyproject = get_pyproject_data()
    deps = pyproject["project"]["dependencies"]
    core_deps = sorted([reqtify(d_spec) for d_spec in deps])

    extras = pyproject["project"]["optional-dependencies"]
    extra_outputs = {
        extra: sorted([reqtify(d_spec) for d_spec in extra_deps])
        for extra, extra_deps in extras.items()
        if extra not in SKIP_EXTRAS
    }

    extra_outputs = {
        extra: sorted(sum([EXTRA_EXTRA_DEPS.get(dep, []) for dep in deps], deps))
        for extra, deps in extra_outputs.items()
    }

    context = dict(
        version=VERSION,
        build_number=BUILD_NUMBER,
        sha256_sum=SHA256_SUM,
        extra_outputs=extra_outputs,
        core_deps=core_deps,
        extra_test_imports=EXTRA_TEST_IMPORTS,
        extra_test_commands=EXTRA_TEST_COMMANDS,
        min_python=MIN_PYTHON,
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
