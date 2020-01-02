# -*- coding: utf-8 -*-
# imagecodecs/setup.py

"""Imagecodecs package setuptools script."""

import sys
import os
import re

from setuptools import setup, Extension
from setuptools.command.build_ext import build_ext as _build_ext

buildnumber = ''  # 'post0'

with open('imagecodecs/_imagecodecs.pyx') as fh:
    code = fh.read()

version = re.search(r"__version__ = '(.*?)'", code).groups()[0]

version += ('.' + buildnumber) if buildnumber else ''

description = re.search(r'"""(.*)\.(?:\r\n|\r|\n)', code).groups()[0]

readme = re.search(r'(?:\r\n|\r|\n){2}"""(.*)"""(?:\r\n|\r|\n){2}__version__',
                   code, re.MULTILINE | re.DOTALL).groups()[0]

readme = '\n'.join([description, '=' * len(description)] +
                   readme.splitlines()[1:])

license = re.search(r'(# Copyright.*?(?:\r\n|\r|\n))(?:\r\n|\r|\n)+""', code,
                    re.MULTILINE | re.DOTALL).groups()[0]

license = license.replace('# ', '').replace('#', '')

if 'sdist' in sys.argv:
    with open('LICENSE', 'w') as fh:
        fh.write('BSD 3-Clause License\n\n')
        fh.write(license)
    with open('README.rst', 'w') as fh:
        fh.write(readme)


sources = [
    'imagecodecs/opj_color.c',
    'imagecodecs/jpeg_sof3.cpp',
    'imagecodecs/_imagecodecs.pyx',
]

include_dirs = [
    'imagecodecs',
]

library_dirs = []
libraries = [
    'zlib', 'liblz4', 'libbz2', 'zstd', 'liblzma',
    'aec', 'blosc', 'snappy', 'zopfli',
    'brotlienc', 'brotlidec', 'brotlicommon',
    'jpeg-static',
    'turbojpeg-static',
    'libpng', 'libwebp', 'openjp2', 'libjpegxr', 'libjxrglue', 'lcms',
]
define_macros = [
    ('WIN32', 1),
    ('LZMA_API_STATIC', 0),
    ('OPJ_STATIC', 0),
    ('OPJ_HAVE_LIBLCMS2', 1),
    ('CHARLS_STATIC', 0)
]

libraries_jpegls = ['charls-2-x64']
libraries_jpegxl = []
libraries_zfp = []
openmp_args = ['/openmp']
# include_dirs.extend(os.environ.get('INCLUDE', '').split(';'))
LIBRARY_INC = os.environ.get('LIBRARY_INC', '')
for inc_dir in ['openjpeg-2.3', 'jxrlib', 'libpng16', 'webp', 'lzma']:
    include_dirs.append(LIBRARY_INC + '\\' + inc_dir)
include_dirs.append(LIBRARY_INC)

libraries_jpeg12 = []  # ['jpeg12']

if 'lzf' not in libraries and 'liblzf' not in libraries:
    # use liblzf sources from sdist
    sources.extend([
        'liblzf-3.6/lzf_c.c',
        'liblzf-3.6/lzf_d.c',
    ])
    include_dirs.append('liblzf-3.6')

if 'bitshuffle' not in libraries and 'libbitshuffle' not in libraries:
    # use bitshuffle sources from sdist
    sources.extend([
        'bitshuffle-0.3.5/bitshuffle_core.c',
        'bitshuffle-0.3.5/iochain.c',
    ])
    include_dirs.append('bitshuffle-0.3.5')


class build_ext(_build_ext):
    """Delay import numpy until build."""
    def finalize_options(self):
        _build_ext.finalize_options(self)
        __builtins__.__NUMPY_SETUP__ = False
        import numpy
        self.include_dirs.append(numpy.get_include())


# Work around "Cython in setup_requires doesn't work"
# https://github.com/pypa/setuptools/issues/1317
try:
    import Cython  # noqa
    ext = '.pyx'
except ImportError:
    ext = '.c'

ext_modules = []

ext_modules += [
    Extension(
        'imagecodecs._imagecodecs_lite',
        ['imagecodecs/imagecodecs.c', 'imagecodecs/_imagecodecs_lite' + ext],
        include_dirs=['imagecodecs'],
        libraries=[] if sys.platform == 'win32' else ['m'],
        library_dirs=library_dirs,
    ),
    Extension(
        'imagecodecs._imagecodecs',
        sources,
        include_dirs=include_dirs,
        library_dirs=library_dirs,
        libraries=libraries,
        define_macros=define_macros,
    )
]

if libraries_jpeg12:
    ext_modules += [
        Extension(
            'imagecodecs._jpeg12',
            ['imagecodecs/_jpeg12' + ext],
            include_dirs=include_dirs,
            library_dirs=library_dirs,
            libraries=libraries_jpeg12,
            define_macros=[('BITS_IN_JSAMPLE', 12)],
        )
    ]

if libraries_jpegls:
    ext_modules += [
        Extension(
            'imagecodecs._jpegls',
            ['imagecodecs/_jpegls' + ext],
            include_dirs=include_dirs,
            library_dirs=library_dirs,
            libraries=libraries_jpegls,
            define_macros=define_macros,
        )
    ]

if libraries_jpegxl:
    ext_modules += [
        Extension(
            'imagecodecs._jpegxl',
            ['imagecodecs/_jpegxl' + ext],
            include_dirs=include_dirs,
            library_dirs=library_dirs,
            libraries=libraries_jpegxl,
            define_macros=define_macros,
        )
    ]

if libraries_zfp:
    ext_modules += [
        Extension(
            'imagecodecs._zfp',
            ['imagecodecs/_zfp' + ext],
            include_dirs=include_dirs,
            library_dirs=library_dirs,
            libraries=libraries_zfp,
            define_macros=define_macros,
            extra_compile_args=openmp_args
        )
    ]

setup(
    name='imagecodecs',
    version=version,
    description=description,
    long_description=readme,
    author='Christoph Gohlke',
    author_email='cgohlke@uci.edu',
    url='https://www.lfd.uci.edu/~gohlke/',
    python_requires='>=2.7',
    install_requires=['numpy>=1.14.5', 'pathlib;python_version=="2.7"'],
    setup_requires=['setuptools>=18.0', 'numpy>=1.14.5'],  # 'cython>=0.29.14'
    extras_require={'all': ['matplotlib>=2.2', 'tifffile>=2019.7.2']},
    tests_require=['pytest', 'tifffile', 'czifile', 'blosc', 'zstd', 'lz4',
                   'python-lzf', 'bitshuffle', 'zopflipy'],  # zfpy
    packages=['imagecodecs'],
    package_data={'imagecodecs': ['licenses/*']},
    entry_points={
        'console_scripts': ['imagecodecs=imagecodecs.__main__:main']},
    ext_modules=ext_modules,
    cmdclass={'build_ext': build_ext},
    license='BSD',
    zip_safe=False,
    platforms=['any'],
    classifiers=[
        'Development Status :: 3 - Alpha',
        'License :: OSI Approved :: BSD License',
        'Intended Audience :: Science/Research',
        'Intended Audience :: Developers',
        'Operating System :: OS Independent',
        'Programming Language :: C',
        'Programming Language :: Cython',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: Implementation :: CPython',
    ],
)
