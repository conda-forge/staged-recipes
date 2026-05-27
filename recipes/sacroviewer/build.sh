#!/bin/bash

# Build assets
npm install
if [ $? -ne 0 ]; then exit 1; fi
npm run build
if [ $? -ne 0 ]; then exit 1; fi

# Collect static files
export SECRET_KEY=dummy
export STATIC_ROOT="${SRC_DIR}/sacro/static/sacro"
$PYTHON manage.py collectstatic --no-input
if [ $? -ne 0 ]; then exit 1; fi

# Ensure we use our custom setup.py
rm -f pyproject.toml

cat <<EOF > setup.py
import os
from setuptools import setup, find_packages
setup(
    name="sacroviewer",
    version=os.environ.get("PKG_VERSION", "0.0.0"),
    packages=find_packages(exclude=["tests*", "docs*"]),
    include_package_data=True,
    package_data={"": ["templates/*", "templates/**/*", "static/*", "static/**/*"]}
)
EOF

# Patch views.py to use CWD for outputs and avoid 404 if missing
$PYTHON -c "import pathlib, re; p = pathlib.Path('sacro/views.py'); c = p.read_text(); c = c.replace('Path(settings.BASE_DIR) / \"outputs\"', 'Path.cwd() / \"outputs\"'); c = re.sub(r'if not dirpath\.exists\(\):\s+raise Http404\(f\"Directory not found: \{dirpath\}\"\)', 'if not dirpath.exists():\n          dirpath.mkdir(parents=True, exist_ok=True)', c); p.write_text(c)"

# Install package
$PYTHON -m pip install . -vv --no-deps
if [ $? -ne 0 ]; then exit 1; fi
