#!/bin/sh
# Add path for wanted dependencies
for l in \
    assimp \
    bullet \
    ffmpeg \
    freetype \
    jpeg \
    openal \
    openssl \
    openexr \
    png \
    python \
    tiff \
    vorbis \
    zlib
do
    export ADDITIONAL_OPTIONS=--$l-incdir\ $PREFIX/include\ $ADDITIONAL_OPTIONS
    export ADDITIONAL_OPTIONS=--$l-libdir\ $PREFIX/lib\ $ADDITIONAL_OPTIONS
done
# Special treatment for eigen
export ADDITIONAL_OPTIONS=--eigen-incdir\ $PREFIX/include/eigen3\ $ADDITIONAL_OPTIONS

# Exclude unwanted dependencies
for l in \
    egl \
    gles \
    gles2
do
    export ADDITIONAL_OPTIONS=--no-$l\ $ADDITIONAL_OPTIONS
done

# Make panda using special panda3d tool
$PYTHON makepanda/makepanda.py \
    --threads=${CPU_COUNT} \
    --wheel \
    --outputdir=build \
    --everything \
    $ADDITIONAL_OPTIONS 2> warnings.txt

tail -n 50 warnings.txt

# Install wheel which install python, bin
$PYTHON -m pip install panda3d*.whl -vv

cd build

# Install lib in sysroot-folder
rsync -a lib               $PREFIX

# Make etc 
mkdir $PREFIX/etc || true
mkdir $PREFIX/etc/panda3d
cp etc/*                   $PREFIX/etc/panda3d

# Make share
mkdir $PREFIX/share/panda3d
rsync -a include           $PREFIX/share/panda3d
rsync -a models            $PREFIX/share/panda3d
rsync -a plugins           $PREFIX/share/panda3d
cp ReleaseNotes            $PREFIX/share/panda3d
cp LICENSE                 $PREFIX/share/panda3d
