#!/bin/bash
set -euxo pipefail

cd build/py-interface/python_package

# Remove the bundled shared library; it is provided by libamd-smi
rm -f amdsmi/libamd_smi.so

# Remove the package-data rule that would try to include *.so
sed -i '/\*\.so/d' pyproject.toml

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

# Install the CLI
CLI_DIR="${SRC_DIR}/build/amdsmi_cli/amdsmi_cli"
DEST="${PREFIX}/libexec/amdsmi_cli"
mkdir -p "${DEST}" "${PREFIX}/bin"
cp -a "${CLI_DIR}"/*.py "${CLI_DIR}"/*.md "${DEST}/"
chmod +x "${DEST}/amdsmi_cli.py"
ln -sf "../libexec/amdsmi_cli/amdsmi_cli.py" "${PREFIX}/bin/amd-smi"
