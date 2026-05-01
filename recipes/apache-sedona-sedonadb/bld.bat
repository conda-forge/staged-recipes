@echo off
setlocal enabledelayedexpansion

REM Strip the C extension declaration from pyproject.toml so the resulting
REM wheel is pure Python (noarch). See build.sh for rationale.
"%PYTHON%" -c "import pathlib, re, sys; p=pathlib.Path('pyproject.toml'); t=p.read_text(); pat=re.compile(r'\n*(?:#[^\n]*\n)*\[\[tool\.setuptools\.ext-modules\]\][\s\S]*?(?=\n\[|\Z)'); new,n=pat.subn('\n', t); sys.exit('strip failed') if n!=1 else p.write_text(new)"
if errorlevel 1 exit 1

"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
