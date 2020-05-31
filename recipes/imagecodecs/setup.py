# imagecodecs/setup.py

"""Imagecodecs package setuptools script."""

import sys
import os
import re

from setuptools import setup, Extension
from setuptools.command.build_ext import build_ext as _build_ext

try:
    import pip
    from packaging.version import parse
    import platform
    if parse(pip.__version__) < parse('19.0') and platform.system() == 'Linux':
        print('Installing imagecodecs wheels requires pip >= 19.0')
except ImportError:
    pass

buildnumber = ''  # e.g 'pre1' or 'post1'

base_dir = os.path.dirname(os.path.abspath(__file__))

with open(os.path.join(base_dir, 'imagecodecs/imagecodecs.py')) as fh:
    code = fh.read().replace('\r', '')

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
    # update README, LICENSE, and CHANGES files

    with open('README.rst', 'w') as fh:
        fh.write(readme)

    license = re.search(r'(# Copyright.*?(?:\r\n|\r|\n))(?:\r\n|\r|\n)+""',
                        code, re.MULTILINE | re.DOTALL).groups()[0]

    license = license.replace('# ', '').replace('#', '')

    with open('LICENSE', 'w') as fh:
        fh.write('BSD 3-Clause License\n\n')
        fh.write(license)

    revisions = re.search(r'(?:\r\n|\r|\n){2}(Revisions.*)   \.\.\.', readme,
                          re.MULTILINE | re.DOTALL).groups()[0].strip()

    with open('CHANGES.rst', 'r') as fh:
        old = fh.read()

    d = revisions.splitlines()[-1]
    old = old.split(d)[-1]
    with open('CHANGES.rst', 'w') as fh:
        fh.write(revisions.strip())
        fh.write(old)


OPTIONS = {
    'cythonize': sys.version_info >= (3, 10),
    'include_dirs': ['imagecodecs'],
    'library_dirs': [],
    'libraries': ['m'] if sys.platform != 'win32' else [],
    'define_macros': [('WIN32', 1)] if sys.platform == 'win32' else [],
    'extra_compile_args': [],
}

EXTENSIONS = {
    'shared': dict(),
    'imcd': dict(sources=['imagecodecs/imcd.c']),
    'aec': dict(libraries=['aec']),
    'bitshuffle': dict(
        sources=[
            'bitshuffle-0.3.5/bitshuffle_core.c',
            'bitshuffle-0.3.5/iochain.c',
            ],
        include_dirs=['bitshuffle-0.3.5']
        ),
    'blosc': dict(libraries=['blosc']),
    'brotli': dict(libraries=['brotlienc', 'brotlidec', 'brotlicommon']),
    'bz2': dict(libraries=['bz2']),
    'gif': dict(libraries=['gif']),
    'jpeg2k': dict(
        sources=['imagecodecs/opj_color.c'],
        libraries=['openjp2', 'lcms2'],
        define_macros=[('OPJ_HAVE_LIBLCMS2', 1)]
        ),
    'jpeg8': dict(
        libraries=['jpeg'],
        cython_compile_env={'HAVE_LIBJPEG_TURBO': True}
        ),
    'jpeg12': dict(
        libraries=['jpeg12'],
        define_macros=[('BITS_IN_JSAMPLE', 12)],
        cython_compile_env={'HAVE_LIBJPEG_TURBO': True}
        ),
    'jpegls': dict(libraries=['charls']),
    'jpegsof3': dict(sources=['imagecodecs/jpegsof3.cpp']),
    'jpegxl': dict(libraries=['brunslidec-c', 'brunslienc-c']),
    'jpegxr': dict(
        libraries=['jpegxr', 'jxrglue'],
        define_macros=[('__ANSI__', 1)] if sys.platform != 'win32' else []
        ),
    'lerc': dict(libraries=['lerc']),
    'lz4': dict(libraries=['lz4']),
    'lzf': dict(
        sources=['liblzf-3.6/lzf_c.c', 'liblzf-3.6/lzf_d.c'],
        include_dirs=['liblzf-3.6']
        ),
    'lzma': dict(libraries=['lzma']),
    'png': dict(libraries=['png', 'z']),
    'snappy': dict(libraries=['snappy']),
    # 'szip': dict(libraries=['libaec']),
    'tiff': dict(libraries=['tiff']),
    'webp': dict(libraries=['webp']),
    'zfp': dict(libraries=['zfp']),
    'zlib': dict(libraries=['z']),
    'zopfli': dict(libraries=['zopfli']),
    'zstd': dict(libraries=['zstd']),
    # 'template': dict(
    #     sources=[],
    #     include_dirs=[],
    #     library_dirs=[],
    #     libraries=[],
    #     define_macros=[],
    #     extra_compile_args=[],
    #     cython_compile_env={}
    #     ),
}


def customize_build_default(EXTENSIONS, OPTIONS):
    """Customize build for common platforms: recent Debian, arch..."""
    import platform

    del EXTENSIONS['jpeg12']  # jpeg12 requires custom build
    del EXTENSIONS['jpegls']  # CharLS 2.1 library not commonly available
    del EXTENSIONS['jpegxl']  # Brunsli library not commonly available
    del EXTENSIONS['lerc']  # LERC library not commonly available
    del EXTENSIONS['zfp']  # ZFP library not commonly available

    if 'arch' in platform.platform():
        del EXTENSIONS['zopfli']  # zopfli/zopfli.h does not exist

    if sys.platform == 'win32':
        EXTENSIONS['bz2']['libraries'] = ['libbz2']
    else:
        EXTENSIONS['jpeg2k']['include_dirs'] = ['/usr/include/openjpeg-2.3']
        EXTENSIONS['jpegxr']['include_dirs'] = ['/usr/include/jxrlib']


def customize_build_cg(EXTENSIONS, OPTIONS):
    """Customize build for Windows development environment with static libs."""
    from _inclib import INCLIB

    OPTIONS['include_dirs'].append(INCLIB)
    OPTIONS['library_dirs'].append(INCLIB)

    EXTENSIONS['aec'] = dict(libraries=['libaec'])
    EXTENSIONS['bz2'] = dict(libraries=['libbz2'])
    EXTENSIONS['lzf'] = dict(libraries=['lzf'])
    EXTENSIONS['gif'] = dict(libraries=['libgif'])
    # EXTENSIONS['szip'] = dict(libraries=['libaec'])
    EXTENSIONS['zstd'] = dict(libraries=['zstd_static'])
    EXTENSIONS['jpegls']['define_macros'] = [('CHARLS_STATIC', 1)]
    EXTENSIONS['jpeg2k']['define_macros'] += [('OPJ_STATIC', 1)]
    EXTENSIONS['jpeg2k']['include_dirs'] = [INCLIB + 'openjpeg-2.3']
    EXTENSIONS['jpegxr']['include_dirs'] = [INCLIB + 'jxrlib']
    EXTENSIONS['zfp']['extra_compile_args'] = ['/openmp']
    EXTENSIONS['blosc'] = dict(
        libraries=['libblosc', 'zlib', 'lz4', 'snappy', 'zstd_static']
    )
    EXTENSIONS['brotli'] = dict(
        libraries=[
            'brotlienc-static', 'brotlidec-static', 'brotlicommon-static'
        ]
    )
    EXTENSIONS['lzma'] = dict(
        libraries=['lzma-static'],
        define_macros=[('LZMA_API_STATIC', 1)]
    )
    EXTENSIONS['tiff'] = dict(
        libraries=[
            'tiff', 'z', 'jpeg', 'png', 'webp', 'zstd_static', 'lzma-static',
        ],
        define_macros=[('LZMA_API_STATIC', 1)]
    )
    EXTENSIONS['jpegxl'] = dict(
        libraries=[
            'brunslidec-c', 'brunslienc-c',
            # static linking
            'brunslidec-static', 'brunslienc-static', 'brunslicommon-static',
            # vendored brotli currently used for compressing metadata
            'brunsli_brotlidec-static',
            'brunsli_brotlienc-static',
            'brunsli_brotlicommon-static',
        ]
    )


def customize_build_ci(EXTENSIONS, OPTIONS):
    """Customize build for Czaki's CI environment."""
    del EXTENSIONS['jpeg12']

    if not os.environ.get('SKIP_OMP', False):
        EXTENSIONS['zfp']['extra_compile_args'] = ['-fopenmp']

    base_path = os.environ.get(
        'BASE_PATH', os.path.dirname(os.path.abspath(__file__))
    )
    include_base_path = os.path.join(
        base_path, 'build_utils/libs_build/include'
    )
    OPTIONS['library_dirs'] = [
        x for x in os.environ.get(
            'LD_LIBRARY_PATH', os.environ.get('LIBRARY_PATH', '')
        ).split(':') if x
    ]

    if os.path.exists(include_base_path):
        OPTIONS['include_dirs'].append(include_base_path)
        for el in os.listdir(include_base_path):
            path_to_dir = os.path.join(include_base_path, el)
            if os.path.isdir(path_to_dir):
                OPTIONS['include_dirs'].append(path_to_dir)
        jxr_path = os.path.join(include_base_path, 'libjxr')
        if os.path.exists(jxr_path):
            jpegxr_include_dirs = [jxr_path]
            for el in os.listdir(jxr_path):
                path_to_dir = os.path.join(jxr_path, el)
                if os.path.isdir(path_to_dir):
                    jpegxr_include_dirs.append(path_to_dir)
            EXTENSIONS['jpegxr']['include_dirs'] = jpegxr_include_dirs

    for dir_path in OPTIONS['include_dirs']:
        if os.path.exists(os.path.join(dir_path, 'charls', 'charls.h')):
            break
    else:
        del EXTENSIONS['jpegls']

    for dir_path in OPTIONS['include_dirs']:
        if os.path.exists(os.path.join(dir_path, 'zfp.h')):
            break
    else:
        del EXTENSIONS['zfp']

    for dir_path in OPTIONS['include_dirs']:
        if os.path.exists(os.path.join(dir_path, 'Lerc_c_api.h')):
            break
    else:
        del EXTENSIONS['lerc']


def customize_build_cf(EXTENSIONS, OPTIONS):
    """Customize build for conda-forge."""

    del EXTENSIONS['jpeg12']
    del EXTENSIONS['jpegxl']
    del EXTENSIONS['lerc']
    del EXTENSIONS['zfp']

    # build jpeg8 or jpeg9 against libjpeg instead of libjpeg_turbo
    OPTIONS['cythonize'] = True
    EXTENSIONS['jpeg8']['cython_compile_env']['HAVE_LIBJPEG_TURBO'] = False


    if sys.platform == 'win32':
        library_inc = os.environ.get('LIBRARY_INC', '')
        EXTENSIONS['bz2']['libraries'] = ['bzip2']
        EXTENSIONS['jpeg2k']['include_dirs'] = [
            os.path.join(
                library_inc, 'openjpeg-' + os.environ.get('openjpeg', '2.3')
            )
        ]
        EXTENSIONS['jpegls']['libraries'] = ['charls-2-x64']
        EXTENSIONS['lz4']['libraries'] = ['liblz4']
        EXTENSIONS['lzma']['libraries'] = ['liblzma']
        EXTENSIONS['png']['libraries'] = ['libpng', 'z']
        EXTENSIONS['webp']['libraries'] = ['libwebp']
        EXTENSIONS['jpegxr']['include_dirs'] = [
            os.path.join(os.environ['LIBRARY_INC'], 'jxrlib')
        ]
        EXTENSIONS['jpegxr']['libraries'] = ['libjpegxr', 'libjxrglue']
    else:
        EXTENSIONS['jpegxr']['include_dirs'] = [
            os.path.join(os.environ['PREFIX'], 'include', 'jxrlib')
        ]
        EXTENSIONS['jpegxr']['libraries'] = ['jpegxr', 'jxrglue']


# customize builds based on environment
try:
    from imagecodecs_distributor_setup import customize_build
except ImportError:
    if os.environ.get('COMPUTERNAME', '').startswith('CG-'):
        customize_build = customize_build_cg
    elif os.environ.get('LD_LIBRARY_PATH', os.environ.get('LIBRARY_PATH', '')):
        customize_build = customize_build_ci
    elif os.environ.get('CONDA_BUILD', ''):
        customize_build = customize_build_cf
    else:
        customize_build = customize_build_default

customize_build(EXTENSIONS, OPTIONS)

# use precompiled c files if Cython is not installed
# work around "Cython in setup_requires doesn't work"
# https://github.com/pypa/setuptools/issues/1317
try:
    import Cython  # noqa
    EXT = '.pyx'
except ImportError:
    if OPTIONS['cythonize']:
        raise
    Cython = None
    EXT = '.c'


class build_ext(_build_ext):
    """Customize build of extensions.

    Delay importing numpy until building extensions.
    Add numpy include directory to include_dirs.
    Skip building deselected extensions.
    Cythonize with compile time macros.

    """
    user_options = _build_ext.user_options + (
        [('lite', None, 'only build the _imcd extension')] +
        [(f'skip-{name}', None, f'do not build the _{name} extension')
         for name in EXTENSIONS]
        )

    def initialize_options(self):
        for name in EXTENSIONS:
            setattr(self, f'skip_{name}', False)
        self.lite = False
        _build_ext.initialize_options(self)

    def finalize_options(self):
        _build_ext.finalize_options(self)

        # remove extensions based on user_options
        for ext in self.extensions.copy():
            name = ext.name.rsplit('_', 1)[-1]
            if (
                (self.lite and name not in ('imcd', 'shared')) or
                getattr(self, f'skip_{name}', False)
            ):
                print(f'skipping {ext.name!r} extension (deselected)')
                self.extensions.remove(ext)

        # add numpy include directory
        # delay import of numpy until setup_requires are installed
        # prevent numpy from detecting setup process
        if isinstance(__builtins__, dict):
            __builtins__['__NUMPY_SETUP__'] = False
        else:
            setattr(__builtins__, '__NUMPY_SETUP__', False)
        import numpy
        self.include_dirs.append(numpy.get_include())

        # Cythonize with compile time macros
        if Cython is not None and self.distribution.ext_modules:
            from Cython.Build.Dependencies import cythonize
            for i, ext in enumerate(self.extensions):
                name = ext.name.rsplit('_', 1)[-1]
                cyenv = EXTENSIONS[name].get('cython_compile_env', {})
                if OPTIONS['cythonize'] or cyenv:
                    cythonize(
                        ext,
                        include_path=ext.include_dirs,
                        compile_time_env=cyenv,
                        force=OPTIONS['cythonize']
                    )


def extension(name):
    """Return setuptools Extension."""
    e = EXTENSIONS[name]
    return Extension(
        f'imagecodecs._{name}',
        sources=[f'imagecodecs/_{name}' + EXT] + e.get('sources', []),
        include_dirs=OPTIONS['include_dirs'] + e.get('include_dirs', []),
        library_dirs=OPTIONS['library_dirs'] + e.get('library_dirs', []),
        libraries=OPTIONS['libraries'] + e.get('libraries', []),
        define_macros=OPTIONS['define_macros'] + e.get('define_macros', []),
        extra_compile_args=(
            OPTIONS['extra_compile_args'] + e.get('extra_compile_args', [])
        )
    )


setup(
    name='imagecodecs',
    version=version,
    description=description,
    long_description=readme,
    author='Christoph Gohlke',
    author_email='cgohlke@uci.edu',
    url='https://www.lfd.uci.edu/~gohlke/',
    python_requires='>=3.6',
    install_requires=['numpy>=1.15.1'],
    setup_requires=['setuptools>=18.0', 'numpy>=1.15'],  # 'cython>=0.29.19'
    extras_require={'all': ['matplotlib>=3.1', 'tifffile>=2020.5.25']},
    tests_require=['pytest', 'tifffile', 'czifile', 'blosc', 'zstd', 'lz4',
                   'python-lzf', 'bitshuffle', 'zopflipy'],  # zfpy, brotli
    packages=['imagecodecs'],
    package_data={'imagecodecs': ['licenses/*']},
    entry_points={
        'console_scripts': ['imagecodecs=imagecodecs.__main__:main']},
    ext_modules=[extension(name) for name in sorted(EXTENSIONS)],
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
        'Programming Language :: Python :: 3 :: Only',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: Implementation :: CPython',
    ],
)
