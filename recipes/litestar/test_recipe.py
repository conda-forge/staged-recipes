"""(re-)generate the litestar multi-output recipe based on `pyproject.toml`

Invoke this locally from the root of the feedstock, assuming `tomli`, `jinja2`, and `packaging`:

    python recipe/test_recipe.py --update
    git commit -m "updated recipe with test_recipe.py"
    conda smithy rerender

If not updating, parameter will fail if new `[extra]`s are added, or
dependencies change.

This tries to work with the conda-forge autotick bot by reading updates from
`meta.yml`:

- build_number
- version
- sha256sum

If running locally against a non-bot-requested version, you'll probably need
to update those fields in `meta.yaml`.

If some underlying project data changed e.g. the `path_to-the_tarball`, update
`TEMPLATE` below and re-run.
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

TEMPLATE = """
{% set version = "<< version >>" %}

package:
  name: litestar-split
  version: {{ version }}

source:
  url: https://pypi.io/packages/source/l/litestar/litestar-{{ version }}.tar.gz
  # the SHA256 gets updated by the bot
  sha256: << sha256_sum >>

build:
  # the build number gets reset by the bot
  number: << build_number >>
  noarch: python

requirements:
  host:
    - python << min_python >>
  run:
    - python << min_python >>

outputs:
  - name: litestar
    build:
      noarch: python
      script:
        - {{ PYTHON }} {{ RECIPE_DIR }}/test_recipe.py --check
        - {{ PYTHON }} -m pip install . -vv --no-deps --no-build-isolation --disable-pip-version-check
      entry_points:
        - litestar = litestar.__main__:run_cli
    requirements:
      host:
        - pip
        - hatchling
        - python << min_python >>
        # for `test_recipe.py` preflight
        - jinja2
        - packaging
        - tomli
      run:
        - python << min_python >><% for dep in core_deps %>
        - << dep >>
        <%- endfor %>
    test:
      imports:
        - litestar
      commands:
        - pip check
      requires:
        - pip
    about:
      home: https://litestar.dev
      dev_url: https://github.com/litestar-org/litestar
      doc_url: https://docs.litestar.dev
      summary: Light-weight and flexible ASGI API Framework
      license: MIT
      license_file: LICENSE
<% for extra, extra_deps in extra_outputs.items() %>
  - name: litestar-with-<< extra >>
    build:
      noarch: generic
    requirements:
      run:
        - {{ pin_subpackage("litestar", exact=True) }}<% for dep in extra_deps %>
        - << dep >>
        <%- endfor %>
    test:
      imports:
        - litestar<% if extra in extra_test_imports %>
        - << extra_test_imports[extra] >>
        <%- else %>
        # TODO: import test for << extra >>
        <%- endif %>
      commands:
        - pip check<% if extra in extra_test_commands %>
        - << extra_test_commands[extra] >>
        <%- endif %>
      requires:
        - pip
    about:
      home: https://litestar.dev
      dev_url: https://github.com/litestar-org/litestar
      doc_url: https://docs.litestar.dev
      summary: Light-weight and flexible ASGI API Framework (with << extra >>)
      license: MIT
      license_file: LICENSE
<% endfor %>
  - name: litestar-with-full
    build:
      noarch: python
    requirements:
      host:
        - python << min_python >>
      run:
        - python << min_python >>
        - {{ pin_subpackage("litestar", exact=True) }}
        <%- for extra, extra_deps in extra_outputs.items() %>
        - {{ pin_subpackage("litestar-with-<< extra >>", exact=True) }}
        <%- endfor %>
    test:
      requires:
        - pip
      imports:
        - litestar
      commands:
        - pip check
    about:
      home: https://litestar.dev
      dev_url: https://github.com/litestar-org/litestar
      doc_url: https://docs.litestar.dev
      summary: Light-weight and flexible ASGI API Framework (with all extras)
      license: MIT
      license_file: LICENSE

about:
  home: https://litestar.dev
  dev_url: https://github.com/litestar-org/litestar
  doc_url: https://docs.litestar.dev
  summary: Light-weight and flexible ASGI API Framework
  license: MIT
  license_file: LICENSE

extra:
  feedstock-name: litestar
  recipe-maintainers:
    - bollwyvl
    - thewchan
"""

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
    ("redis-py", ("hiredis",)): "redis-py",
}

#: handle transient extras incurred, keyed by post-transform names
EXTRA_EXTRA_DEPS = {
    # https://github.com/redis/redis-py/blob/v4.5.3/setup.py#L57
    "redis-py": ["hiredis >=1.0.0"],
}

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
    "redis": "litestar.stores.redis",
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
    "sqlalchemy",
]


def reqtify(raw):
    """split dependency into conda requirement"""
    req = Requirement(raw)
    name = req.name
    dep = str(req.specifier)
    name = TRANFORM_DEP.get(name, name).lower()
    if req.extras:
        name = TRANSFORM_EXTRA_DEP[(name, tuple(sorted(req.extras)))]

    return [f"{name} {dep}".strip()]


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


def verify_recipe(update=False):
    """check or update a recipe based on the `pyproject.toml` data"""
    check = not update
    preflight_recipe()
    pyproject = get_pyproject_data()
    deps = pyproject["project"]["dependencies"]
    core_deps = sorted(sum([reqtify(d_spec) for d_spec in deps], []))

    extras = pyproject["project"]["optional-dependencies"]
    extra_outputs = {
        extra: sorted(sum([reqtify(d_spec) for d_spec in extra_deps], []))
        for extra, extra_deps in extras.items()
        if extra not in SKIP_EXTRAS
    }

    extra_outputs = {
        extra: sorted(
            sum([EXTRA_EXTRA_DEPS.get(dep.split(" ")[0], []) for dep in deps], deps)
        )
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

    old_text = META.read_text(encoding="utf-8")
    template = jinja2.Template(TEMPLATE, **DELIMIT)
    new_text = template.render(**context).strip() + "\n"

    if check:
        if new_text.strip() != old_text.strip():
            print(f"{META} is not up-to-date:")
            print(
                "\n".join(
                    difflib.unified_diff(
                        old_text.splitlines(),
                        new_text.splitlines(),
                        META.name,
                        f"{META.name} (updated)",
                    )
                )
            )
            print("either apply the above patch, or run locally:")
            print("\n\tpython recipe/test_recipe.py --update\n")
            return 1
    else:
        META.write_text(new_text, encoding="utf-8")

    return 0


if __name__ == "__main__":
    sys.exit(verify_recipe(update="--update" in sys.argv))
