# Get Python bin and include directories for the extension build:  
py_bin_path=$($PYTHON -c "from sysconfig import get_paths as gp; print(gp()['scripts'])")
py_include_path=$($PYTHON -c "from sysconfig import get_paths as gp; print(gp()['include'])")

# Build JS-package:
#./gradlew js-package:jsBrowserProductionWebpack -Pbuild_release=true -Penable_python_package=false -Parchitecture=x86_64
# Build Python extension:
./gradlew python-extension:build -Pbuild_release=true -Ppython.bin_path=${py_bin_path} -Ppython.include_path=${py_include_path} -Penable_python_package=true -Parchitecture=x86_64
# Build Python package
$PYTHON -m pip install ./python-package -vv