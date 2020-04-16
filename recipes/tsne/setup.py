"""
To upload a new version:
1. make clean
2. git tag a new version: git tag v1.x.x
3. python setup.py sdist
4. python setup.py sdist register upload
"""


import distro
import os
import sys
import platform

from distutils.core import setup
from setuptools import find_packages
from distutils.extension import Extension

import versioneer
import numpy
from Cython.Distutils import build_ext
from Cython.Build import cythonize


def read_file(filename):
    filepath = os.path.join(
        os.path.dirname(os.path.dirname(__file__)), filename)
    if os.path.exists(filepath):
        return open(filepath).read()
    else:
        return ''


if sys.platform == 'darwin':
    # OS X
    version, _, _ = platform.mac_ver()
    parts = version.split('.')
    # v1 = int(parts[0])
    v2 = int(parts[1])
    # v3 = int(parts[2]) if len(parts) == 3 else None

    if v2 >= 10:
        # More than 10.10
        extra_compile_args=['-I/System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/Headers']
    else:
        extra_compile_args=['-I/System/Library/Frameworks/vecLib.framework/Headers']

    ext_modules = [Extension(name='bh_sne',
                   sources=['tsne/bh_sne_src/quadtree.cpp', 'tsne/bh_sne_src/tsne.cpp', 'tsne/bh_sne.pyx'],
                   include_dirs=[numpy.get_include(), 'tsne/bh_sne_src/'],
                   extra_compile_args=extra_compile_args,
                   extra_link_args=['-Wl,-framework', '-Wl,Accelerate', '-lcblas'],
                   language='c++')]
else:
    extra_link_args = ['-lcblas']
    dist = distro.linux_distribution()[0].lower()
    redhat_dists = set(["redhat", "fedora", "centos"])
    if dist in redhat_dists:
        extra_link_args = ['-lsatlas']

    # LINUX
    ext_modules = [Extension(name='bh_sne',
                   sources=['tsne/bh_sne_src/quadtree.cpp', 'tsne/bh_sne_src/tsne.cpp', 'tsne/bh_sne.pyx'],
                   include_dirs=[numpy.get_include(), '/usr/local/include', 'tsne/bh_sne_src/'],
                   library_dirs=['/usr/local/lib'],
                   extra_compile_args=['-msse2', '-O3', '-fPIC', '-w'],
                   extra_link_args=extra_link_args,
                   language='c++')]

ext_modules = cythonize(ext_modules)

with open('requirements.txt') as f:
    required = f.read().splitlines()

cmdclass = versioneer.get_cmdclass()
cmdclass['build_ext'] = build_ext

setup(name='tsne',
    version=versioneer.get_version(),
    cmdclass=versioneer.get_cmdclass(),
    author='Daniel Rodriguez',
    author_email='df.rodriguez@gmail.com',
    url='https://github.com/danielfrg/py_tsne',
    description='TSNE implementations for python',
    long_description=read_file('README.md'),
    long_description_content_type="text/markdown",
    license='Apache License Version 2.0',
    packages=find_packages(),
    ext_modules=ext_modules,
    install_requires=required
)
