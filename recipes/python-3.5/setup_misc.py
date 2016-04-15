# used to build the tk interface on 64-bit darwin
import sys
from distutils.core import setup, Extension


setup(
    ext_modules = [
        Extension(
            '_sqlite3', ['_sqlite/cache.c',
                         '_sqlite/connection.c',
                         '_sqlite/cursor.c',
                         '_sqlite/microprotocols.c',
                         '_sqlite/module.c',
                         '_sqlite/prepare_protocol.c',
                         '_sqlite/row.c',
                         '_sqlite/statement.c',
                         '_sqlite/util.c',],
            define_macros=[('MODULE_NAME', '"sqlite3"')],
            libraries = ['sqlite3'],
            include_dirs = [sys.prefix + '/include'],
            library_dirs = [sys.prefix + '/lib'],
        ),
        Extension(
            '_ssl', ['_ssl.c'],
            libraries = ['ssl', 'crypto'],
            depends = ['socketmodule.h'],
            include_dirs = [sys.prefix + '/include'],
            library_dirs = [sys.prefix + '/lib'],
        ),
        Extension(
            '_hashlib', ['_hashopenssl.c'],
            libraries = ['ssl', 'crypto'],
            include_dirs = [sys.prefix + '/include'],
            library_dirs = [sys.prefix + '/lib'],
        ),
        Extension(
            '_tkinter', ['_tkinter.c', 'tkappinit.c'],
            define_macros=[('WITH_APPINIT', 1)],
            libraries=['tcl8.5', 'tk8.5'],
            include_dirs = [sys.prefix + '/include', '/usr/X11R6/include'],
            library_dirs = [sys.prefix + '/lib'],
        ),
    ],
)
