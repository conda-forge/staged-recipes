"""
splore

Scroll through and exploring data sets of molecules
"""
import sys

from setuptools import setup, find_packages

import versioneer

short_description = __doc__.split("\n")

# from https://github.com/pytest-dev/pytest-runner#conditional-requirement
needs_pytest = {'pytest', 'test', 'ptr'}.intersection(sys.argv)
pytest_runner = ['pytest-runner'] if needs_pytest else []

try:
    with open("README.md", "r") as handle:
        long_description = handle.read()
except IOError:
    long_description = "\n".join(short_description[2:])


setup(
    name='splore',
    author='Simon Boothroyd',
    description=short_description[0],
    long_description=long_description,
    long_description_content_type="text/markdown",
    version=versioneer.get_version(),
    cmdclass=versioneer.get_cmdclass(),
    license='MIT',
    packages=find_packages(),
    include_package_data=True,
    setup_requires=[] + pytest_runner,
    entry_points={
        'console_scripts': [
            'splore=splore.cli:main',
        ],
    },
)
