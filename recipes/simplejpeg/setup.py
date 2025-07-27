# hmaarrfk -- 2025/07
# I basically took mostof the setup.py file and deleted much of it since it was
# related to downloading libjpeg-turbo and building it.
# By using conda-forge's libjpeg-turbo, we can avoid that complexity.
# The patch was so extensive that I just wanted to start fresh.
import os
import os.path as pt
import re
import platform
import sys

import numpy as np

from setuptools import setup
from setuptools import find_packages
from setuptools import Extension

# don't require Cython for building
try:
    from Cython.Build import cythonize
    HAVE_CYTHON = True
except ImportError:
    def cythonize(*_, **__):
        pass
    HAVE_CYTHON = False

PACKAGE_DIR = pt.abspath(pt.dirname(__file__))
OS = platform.system().lower()
NPY_API_VERSION = 'NPY_1_19_API_VERSION'

def make_jpeg_module():
    include_dirs = [
        np.get_include(),
        pt.join(PACKAGE_DIR, 'simplejpeg'),
    ]
    cython_files = [pt.join('simplejpeg', '_jpeg.pyx')]
    for cython_file in cython_files:
        if pt.exists(cython_file):
            cythonize(cython_file)
    sources = [
        pt.join('simplejpeg', '_jpeg.c'),
        pt.join('simplejpeg', '_color.c')
    ]
    extra_link_args = []
    extra_compile_args = []
    macros = [
        ('NPY_NO_DEPRECATED_API', NPY_API_VERSION),
        ('NPY_TARGET_VERSION', NPY_API_VERSION),
    ]
    if OS == 'linux':
        extra_link_args.extend([
            '-Wl,'  # following are linker options
            '--strip-all,'  # Remove all symbols
            '--exclude-libs,ALL,'  # Do not export symbols
            '--gc-sections'  # Remove unused sections
        ])
        extra_compile_args.extend([
            '-flto',  # enable LTO
        ])
    return Extension(
        'simplejpeg._jpeg',
        sources,
        language='C',
        include_dirs=include_dirs,
        libraries=['turbojpeg'],
        extra_link_args=extra_link_args,
        extra_compile_args=extra_compile_args,
        define_macros=macros,
    )


# define extensions
ext_modules = [make_jpeg_module()]


def read(*names):
    with open(pt.join(PACKAGE_DIR, *names), encoding='utf8') as f:
        return f.read()


# pip's single-source version method as described here:
# https://python-packaging-user-guide.readthedocs.io/single_source_version/
def find_version(*file_paths):
    version_file = read(*file_paths)
    version_match = re.search(r'^__version__ = [\'"]([^\'"]*)[\'"]',
                              version_file, re.M)
    if version_match:
        return version_match.group(1)
    raise RuntimeError('Unable to find version string.')


def find_package_data(packages, patterns):
    package_data = {
        package: patterns
        for package in packages
    }
    return package_data


packages = find_packages(
    include=['simplejpeg', 'simplejpeg.*'],
)

include_package_data = find_package_data(packages, ('*.pyi',))
exclude_package_data = find_package_data(packages, ('*.h', '*.c', '*.pyx'))

with open(pt.join(PACKAGE_DIR, 'requirements.txt')) as fp:
    dependencies = [line.strip(' \n') for line in fp]

setup(
    name='simplejpeg',
    version=find_version('simplejpeg', '__init__.py'),
    packages=packages,
    package_data=include_package_data,
    exclude_package_data=exclude_package_data,
    install_requires=dependencies,
    ext_modules=ext_modules,
    zip_safe=False,
)
