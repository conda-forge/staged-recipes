# -*- coding: utf-8 -*-
# imagecodecs/setup.py

"""Imagecodecs package setuptools script."""

import sys
import re
import os

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
        fh.write(license)
    with open('README.rst', 'w') as fh:
        fh.write(readme)

base_path = os.environ.get(
    "BASE_PATH", os.path.dirname(os.path.abspath(__file__)))

sources = [
    'imagecodecs/opj_color.c',
    'imagecodecs/jpeg_sof3.cpp',
    'imagecodecs/_imagecodecs.pyx',
]

include_dirs = [
    'imagecodecs',
]

library_dirs = [x for x in os.environ.get("LD_LIBRARY_PATH", os.environ.get("LIBRARY_PATH", "")).split(":") if x]

include_base_path = os.path.join(base_path, "build_utils/libs_build/include")
if os.path.exists(include_base_path):
    include_dirs.append(include_base_path)
    for el in os.listdir(include_base_path):
        path_to_dir = os.path.join(include_base_path, el)
        if os.path.isdir(path_to_dir):
            include_dirs.append(path_to_dir)
    jxr_path = os.path.join(include_base_path, "libjxr")
    if os.path.exists(jxr_path):
        for el in os.listdir(jxr_path):
            path_to_dir = os.path.join(jxr_path, el)
            if os.path.isdir(path_to_dir):
                include_dirs.append(path_to_dir)

try:
    # running in Windows development environment
    import _inclib  # noqa
    libraries = [
        'zlib', 'lz4', 'webp', 'png', 'jxrlib', 'jpeg', 'lzf', 'libbz2',
        'libblosc', 'snappy', 'zstd_static', 'lzma-static', 'openjp2',
        'lcms2']
    define_macros = [('WIN32', 1), ('LZMA_API_STATIC', 1),
                     ('OPJ_STATIC', 1), ('OPJ_HAVE_LIBLCMS2', 1),
                     ('CHARLS_STATIC', 1)]
    libraries_jpeg12 = ['jpeg12']
    if sys.version_info < (3, 5):
        # clarls-2.0 not compatible with msvc 9 or 10
        libraries_jpegls = []
    else:
        libraries_jpegls = ['charls']
    libraries_zfp = ['zfp']
    openmp_args = ['/openmp']

except ImportError:
    # this works with most recent Debian
    libraries = ['jpeg', 'lz4', 'zstd', 'lzma', 'bz2', 'png', 'webp', 'blosc',
                 'openjp2', 'jxrglue', 'jpegxr', 'lcms2', 'z']
    include_dirs.extend(
        ['/usr/include/jxrlib',
         '/usr/include/openjpeg-2.1',
         '/usr/include/openjpeg-2.2',
         '/usr/include/openjpeg-2.3'])
    define_macros = [('OPJ_HAVE_LIBLCMS2', 1)]
    if sys.platform == 'win32':
        define_macros.extend([('WIN32', 1), ('CHARLS_STATIC', 1)])
    else:
        libraries.append('m')
    if os.environ.get('JPEG12_INCLUDE', '') != '':
        libraries_jpeg12 = ['jpeg12']
    else:
        libraries_jpeg12 = []
    for dir_path in include_dirs:
        if os.path.exists(os.path.join(dir_path, "charls.h")):
            libraries_jpegls = ["CharLS"]
            break
    else:
        libraries_jpegls = []  # 'CharLS'
    for dir_path in include_dirs:
        if os.path.exists(os.path.join(dir_path, "zfp.h")):
            libraries_zfp = ["zfp"]
            break
    else:
        libraries_zfp = []  # 'CharLS'
    openmp_args = [] if os.environ.get("SKIP_OMP", False) else ['-fopenmp']


if 'lzf' not in libraries and 'liblzf' not in libraries:
    # use liblzf sources from sdist
    sources.extend(['liblzf-3.6/lzf_c.c', 'liblzf-3.6/lzf_d.c'])
    include_dirs.append('liblzf-3.6')

print("aaa", 'bitshuffle' not in libraries, )
if 'bitshuffle' not in libraries and 'bitshuffle' not in libraries:
    print("bbb")
    # use bitshuffle sources from sdist
    sources.extend(['bitshuffle-0.3.5/bitshuffle_core.c',
                    'bitshuffle-0.3.5/iochain.c'])
    include_dirs.append('bitshuffle-0.3.5')
print("ccc")


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


ext_modules = [
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
        include_dirs=include_dirs + [os.environ.get('JPEG8_INCLUDE','')],
        libraries=libraries,
        define_macros=define_macros,
        library_dirs=library_dirs,
    )
]

if libraries_jpeg12:
    ext_modules += [
        Extension(
            'imagecodecs._jpeg12',
            ['imagecodecs/_jpeg12' + ext],
            include_dirs=['imagecodecs', os.environ.get('JPEG12_INCLUDE','')],
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
            libraries=libraries_jpegls,
            library_dirs=library_dirs,
            define_macros=define_macros,
        )
    ]

if libraries_zfp:
    ext_modules += [
        Extension(
            'imagecodecs._zfp',
            ['imagecodecs/_zfp' + ext],
            include_dirs=include_dirs,
            libraries=libraries_zfp,
            library_dirs=library_dirs,
            define_macros=define_macros,
            extra_compile_args=openmp_args,
        )
    ]

setup_args = dict(
    name='imagecodecs',
    version=version,
    description=description,
    long_description=readme,
    author='Christoph Gohlke',
    author_email='cgohlke@uci.edu',
    url='https://www.lfd.uci.edu/~gohlke/',
    python_requires='>=2.7',
    install_requires=['numpy>=1.14.6'],
    setup_requires=['setuptools>=18.0', 'numpy>=1.14.6'],  # , 'cython>=0.29.0'
    extras_require={'all': ['matplotlib>=2.2', 'tifffile>=2019.7.2']},
    tests_require=['pytest', 'tifffile', 'blosc', 'zstd', 'lz4',
                   'python-lzf', 'scikit-image', 'bitshuffle'],  # zfpy
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
    ],
)

if '--universal' in sys.argv:
    del setup_args['ext_modules']
    del setup_args['cmdclass']
    del setup_args['package_data']

setup(**setup_args)
