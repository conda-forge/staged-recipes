@echo off
:: Strip all entry points except the main one to avoid binary .exe issues (noarch)
%PYTHON% -c "import re, pathlib; p = pathlib.Path('pyproject.toml'); text = p.read_text(); text = re.sub(r'\[project\.scripts\].*?(?=\n\[)', '[project.scripts]\n\"skill-seekers\" = \"skill_seekers.cli.main:main\"\n', text, flags=re.DOTALL); p.write_text(text)"
if errorlevel 1 exit 1
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
