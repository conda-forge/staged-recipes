import setuptools
import os
import codecs

# https://packaging.python.org/guides/single-sourcing-package-version/
def read(*argv):
    here = os.path.abspath(os.path.dirname(__file__))
    with codecs.open(os.path.join(here, *argv), "r") as fp:
        return fp.read()

def get_version():
    for line in read("placekey", "__version__.py").splitlines():
        if line.startswith("__version__"):
            delim = '"' if '"' in line else "'"
            return line.split(delim)[1]
    raise RuntimeError("Unable to find version string.")

long_description = read("README.md")
version = get_version()

setuptools.setup(
    name="placekey",
    version=version,
    author="SafeGraph Inc.",
    author_email="russ@safegraph.com",
    description="Utilities for working with Placekeys",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/Placekey/placekey-py",
    packages=setuptools.find_packages(),
    install_requires=['h3', 'shapely', 'requests', 'ratelimit', 'backoff'],
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: Apache Software License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.6",
)
