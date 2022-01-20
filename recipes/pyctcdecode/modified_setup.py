# Copyright 2021-present Kensho Technologies, LLC.
import codecs
import logging
import os
import re

from setuptools import find_packages, setup  # type: ignore


logger = logging.getLogger(__name__)


def read_file(filename: str) -> str:
    """Read package file as text to get name and version."""
    # intentionally *not* adding an encoding option to open, see here:
    # https://github.com/pypa/virtualenv/issues/201#issuecomment-3145690
    here = os.path.abspath(os.path.dirname(__file__))
    with codecs.open(os.path.join(here, "pyctcdecode", filename, encoding="utf-8"), "r") as f:
        return f.read()


def find_version() -> str:
    """Only define version in one place."""
    version_file = read_file("__init__.py")
    version_match = re.search(r"^__version__ = [\"\']([^\"\']*)[\"\']", version_file, re.M)
    if version_match:
        return version_match.group(1)
    raise RuntimeError("Unable to find version string.")


def find_name() -> str:
    """Only define name in one place."""
    name_file = read_file("__init__.py")
    name_match = re.search(r"^__package_name__ = [\"\']([^\"\']*)[\"\']", name_file, re.M)
    if name_match:
        return name_match.group(1)
    raise RuntimeError("Unable to find name string.")


def find_long_description() -> str:
    """Return the content of the README.md file."""
    return read_file("../README.md")


# upper limits are untested, not necessarily conflicting
# lower limits mostly to be python 3 compatible
REQUIRED_PACKAGES = ["numpy>=1.15.0,<2.0.0", "pygtrie>=2.1,<3.0", "hypothesis>=6.14,<7"]

EXTRAS_REQUIRE = {
    "dev": [
        "bandit",
        "black",
        "codecov",
        "flake8",
        "huggingface-hub",
        "isort>=5.0.0,<6",
        "jupyter",
        "mypy",
        "nbconvert",
        "nbformat",
        "pydocstyle",
        "pylint",
        "pytest",
        "pytest-cov",
    ]
}

setup(
    name=find_name(),
    version=find_version(),
    description="CTC beam search decoder for speech recognition.",
    long_description=find_long_description(),
    long_description_content_type="text/markdown",
    url="https://github.com/kensho-technologies/pyctcdecode",
    author="Kensho Technologies, LLC.",
    author_email="pyctcdecode-maintainer@kensho.com",
    license="Apache 2.0",
    packages=find_packages(),
    install_requires=REQUIRED_PACKAGES,
    extras_require=EXTRAS_REQUIRE,
    package_data={
        "": ["tests/sample_data/bugs_bunny_kenlm.arpa", "tests/sample_data/libri_logits.json"]
    },
    dependency_links=[],
)