@echo off
setlocal

:: 1. Generate sqlite-vec.h using Python (avoids needing make/gettext on Windows)
%PYTHON% -c "t=open('sqlite-vec.h.tmpl', encoding='utf-8').read(); open('sqlite-vec.h', 'w', encoding='utf-8').write(t.replace('${VERSION}', 'v%PKG_VERSION%'))"
if errorlevel 1 exit 1

:: 2. Compile the loadable SQLite extension into a DLL using MSVC
:: /O2 for optimization, /LD to build a DLL, /I for conda-forge headers
cl.exe /O2 /LD /I"%LIBRARY_INC%" sqlite-vec.c /link /OUT:vec0.dll "%LIBRARY_LIB%\sqlite3.lib"
if errorlevel 1 exit 1

:: 3. Assemble the Python package layout
mkdir build_pkg\sqlite_vec
copy vec0.dll build_pkg\sqlite_vec\
if errorlevel 1 exit 1

:: 4. Generate __init__.py using Python
%PYTHON% -c "import os; init_py = f'''from os import path\nimport sqlite3\n\n__version__ = \"{os.environ['PKG_VERSION']}\"\n__version_info__ = tuple(__version__.split('.'))\n\ndef loadable_path():\n    return path.normpath(path.join(path.dirname(__file__), 'vec0'))\n\ndef load(conn: sqlite3.Connection) -> None:\n    conn.load_extension(loadable_path())\n'''; open('build_pkg/sqlite_vec/__init__.py', 'w', encoding='utf-8').write(init_py)"
if errorlevel 1 exit 1

:: Append the upstream-curated body (serialize_float32/int8, register_numpy)
type extra_init.py >> build_pkg\sqlite_vec\__init__.py
if errorlevel 1 exit 1

:: 5. Generate setup.py using Python
%PYTHON% -c "import os; setup_py = f'''from setuptools import setup\nsetup(\n    name='sqlite-vec',\n    version='{os.environ['PKG_VERSION']}',\n    description='A vector search SQLite extension that runs anywhere',\n    packages=['sqlite_vec'],\n    package_data={{'sqlite_vec': ['vec0.*']}},\n    include_package_data=True,\n    has_ext_modules=lambda: True,\n    python_requires='>=3.9',\n)\n'''; open('build_pkg/setup.py', 'w', encoding='utf-8').write(setup_py)"
if errorlevel 1 exit 1

:: 6. Install the Python package
cd build_pkg
%PYTHON% -m pip install . --no-deps --no-build-isolation -vv
if errorlevel 1 exit 1
