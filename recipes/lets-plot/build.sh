#
# Set paths and links:

base_url="https://github.com/JetBrains/lets-plot/releases/download/${PROJECT_VERSION}"
js_package_distr="js-package/distr/lets-plot.min.js"
js_package_path="js-package/build/dist/js/productionExecutable/"
extension_path="python-extension/build/bin/native/releaseStatic/"

# Get Python bin and include directories for the extension build:  
py_bin_path=$($PYTHON -c "from sysconfig import get_paths as gp; print(gp()['scripts'])")
py_include_path=$($PYTHON -c "from sysconfig import get_paths as gp; print(gp()['include'])")
py_architecture=$($PYTHON -c "import platform; print(platform.machine())")

# Includes JS package to the build:
add_js_package() {
    mkdir -p $js_package_path
    cp $js_package_distr $js_package_path
}

if [ ! -f $extension_path ]; then
   # Run extension build:
   ./gradlew python-extension:build -Pbuild_release=true -Ppython.bin_path=${py_bin_path} -Ppython.include_path=${py_include_path} -Penable_python_package=true -Parchitecture=${py_architecture}
fi

if [ ! -f $js_package_path ]; then
   add_js_package
fi

$PYTHON -m pip install $SRC_DIR/python-package -vv
