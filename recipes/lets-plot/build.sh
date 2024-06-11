#
# Set paths and links:
extension_link="https://github.com/JetBrains/lets-plot/releases/download/${PROJECT_VERSION}/linuxX64Extension.zip" # [linux]
js_package_link="https://github.com/JetBrains/lets-plot/releases/download/${PROJECT_VERSION}/lets-plot.min.js" # [linux]
js_package_path="js-package/build/dist/js/productionExecutable/"
extension_path="python-extension/build/bin/native/releaseStatic/" # [linux]

# Downloads and includes python-extension libraries to the build:
add_extension() {
    mkdir -p $extension_path
    curl -OL $extension_link
    unzip linuxX64Extension.zip
    mv linuxX64Extension/* $extension_path
}

# Downloads and includes JS package to the build
add_js_package() {
    mkdir -p $js_package_path
    curl -OL $js_package_link
    mv lets-plot.min.js $js_package_path
}


add_extension # [linux]
add_js_package

$PYTHON -m pip install $SRC_DIR/python-package -vv
