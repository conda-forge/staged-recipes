@echo on

:: 1. Generate sqlite-vec.h using Python
:: We write a tiny python script to disk to avoid inline batch escaping errors
echo import os > make_header.py
echo t = open('sqlite-vec.h.tmpl', encoding='utf-8').read() >> make_header.py
echo v = os.environ.get('PKG_VERSION', '0.1.9') >> make_header.py
echo with open('sqlite-vec.h', 'w', encoding='utf-8') as f: >> make_header.py
echo     f.write(t.replace('${VERSION}', 'v' + v)) >> make_header.py

%PYTHON% make_header.py
if errorlevel 1 exit 1

:: 2. Compile the loadable SQLite extension into a DLL using MSVC
cl.exe /O2 /LD /I"%LIBRARY_INC%" sqlite-vec.c /link /OUT:vec0.dll "%LIBRARY_LIB%\sqlite3.lib"
if errorlevel 1 exit 1

mkdir build_pkg\sqlite_vec
copy vec0.dll build_pkg\sqlite_vec\
if errorlevel 1 exit 1

:: 3. Assemble the Python package layout
:: We write a python script to generate __init__.py and setup.py securely
echo import os > make_pkg.py
echo v = os.environ.get('PKG_VERSION', '0.1.9') >> make_pkg.py
echo lines = [ >> make_pkg.py
echo     "from os import path", >> make_pkg.py
echo     "import sqlite3", >> make_pkg.py
echo     f"__version__ = '{v}'", >> make_pkg.py
echo     "__version_info__ = tuple(__version__.split('.'))", >> make_pkg.py
echo     "def loadable_path():", >> make_pkg.py
echo     "    return path.normpath(path.join(path.dirname(__file__), 'vec0'))", >> make_pkg.py
echo     "def load(conn):", >> make_pkg.py
echo     "    conn.load_extension(loadable_path())" >> make_pkg.py
echo ] >> make_pkg.py
echo with open('build_pkg/sqlite_vec/__init__.py', 'w', encoding='utf-8') as f: >> make_pkg.py
echo     f.write('\n'.join(lines) + '\n') >> make_pkg.py
echo with open('extra_init.py', 'r', encoding='utf-8') as f: >> make_pkg.py
echo     extra = f.read() >> make_pkg.py
echo with open('build_pkg/sqlite_vec/__init__.py', 'a', encoding='utf-8') as f: >> make_pkg.py
echo     f.write('\n' + extra) >> make_pkg.py

echo setup_lines = [ >> make_pkg.py
echo     "from setuptools import setup", >> make_pkg.py
echo     "setup(", >> make_pkg.py
echo     "    name='sqlite-vec',", >> make_pkg.py
echo     f"    version='{v}',", >> make_pkg.py
echo     "    description='A vector search SQLite extension that runs anywhere',", >> make_pkg.py
echo     "    packages=['sqlite_vec'],", >> make_pkg.py
echo     "    package_data={'sqlite_vec': ['vec0.*']},", >> make_pkg.py
echo     "    include_package_data=True,", >> make_pkg.py
echo     "    has_ext_modules=lambda: True,", >> make_pkg.py
:: Note: We use chr(62) to generate the greater-than symbol ('>') to avoid batch redirection errors!
echo     f"    python_requires='{chr(62)}=3.9',", >> make_pkg.py
echo     ")" >> make_pkg.py
echo ] >> make_pkg.py
echo with open('build_pkg/setup.py', 'w', encoding='utf-8') as f: >> make_pkg.py
echo     f.write('\n'.join(setup_lines) + '\n') >> make_pkg.py

%PYTHON% make_pkg.py
if errorlevel 1 exit 1

:: 4. Install the Python package
cd build_pkg
%PYTHON% -m pip install . --no-deps --no-build-isolation -vv
if errorlevel 1 exit 1
