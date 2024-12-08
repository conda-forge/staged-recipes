#
# Set paths and links:

base_url="https://github.com/JetBrains/lets-plot/releases/download/${PROJECT_VERSION}"
js_package_link="${base_url}/lets-plot.min.js"
js_package_path="js-package/build/dist/js/productionExecutable/"
extension_path="python-extension/build/bin/native/releaseStatic/"

# Downloads and includes python-extension libraries to the build:
add_extension() {
    if [ ${target_platform} == "linux-64" ]; then
       package_name="linuxX64Extension"
    elif [ ${target_platform} == "osx-64" ]; then
       package_name="macosX64Extension"
    fi
    mkdir -p $extension_path
    curl -OL "${base_url}/${package_name}.zip"
    unzip ${package_name}.zip
    mv ${package_name}/* $extension_path
}

# Downloads and includes JS package to the build
add_js_package() {
    mkdir -p $js_package_path
    curl -OL $js_package_link
    mv lets-plot.min.js $js_package_path
}

if [ ! -f $extension_path ]; then
   add_extension
fi

if [ ! -f $js_package_path ]; then
   add_js_package
fi

$PYTHON -m pip install $SRC_DIR/python-package -vv
