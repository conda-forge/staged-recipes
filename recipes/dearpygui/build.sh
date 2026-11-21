#!/bin/bash
set -ex

# Remove bundled ImGuiFileDialog.h so the system header (v0.6.7) is used.
# The directory is kept in the include path for DearPyGui-specific CustomFont files.
rm -f thirdparty/ImGuiFileDialog/ImGuiFileDialog.h

mkdir -p cmake-build-local
cd cmake-build-local

cmake .. \
    -DMVDIST_ONLY=True \
    -DMVDPG_VERSION="${PKG_VERSION}" \
    -DMV_PY_VERSION="${PY_VER}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    ${CMAKE_ARGS}

cd ..
cmake --build cmake-build-local --config Release

# Patch setup.py:
# 1. Don't delete our pre-built cmake-build-local directory
# 2. Skip the cmake subprocess calls but keep the shutil.copy that
#    moves the built library into output/dearpygui/
${PYTHON} << 'PATCH'
import pathlib
p = pathlib.Path("setup.py")
t = p.read_text()
t = t.replace('shutil.rmtree(src_path + "/cmake-build-local")', "pass")
t = t.replace("subprocess.check_call(''.join(command), shell=True)", "pass")
t = t.replace("subprocess.check_call(''.join(command), env=os.environ, shell=True)", "pass")
p.write_text(t)
PATCH

${PYTHON} -m pip install . --no-deps --no-build-isolation
