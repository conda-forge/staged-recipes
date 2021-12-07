if [ $(uname) == "Darwin" ]; then
    exit 0;
fi

set -ex
# Add code to install blender at the right place and mark build done. Just expand the tar in the PREFIX.
#
mkdir -p "$PREFIX"
cp -r bin "$PREFIX"
cp -r share "$PREFIX"
