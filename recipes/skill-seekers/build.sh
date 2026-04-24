#!/bin/bash
# Strip all entry points except the main one to avoid binary .exe issues on Windows (noarch)
${PYTHON} -c "
import re, pathlib
p = pathlib.Path('pyproject.toml')
text = p.read_text()
# Replace the [project.scripts] section to only keep the main entry point
text = re.sub(
    r'\[project\.scripts\].*?(?=\n\[)',
    '[project.scripts]\n\"skill-seekers\" = \"skill_seekers.cli.main:main\"\n',
    text,
    flags=re.DOTALL
)
p.write_text(text)
"
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
