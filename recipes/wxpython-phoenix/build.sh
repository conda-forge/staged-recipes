#!/bin/bash

## install wxPython_Phoenix from snapshot build:

pkgname='wxPython_Phoenix'
pip_opts='--pre --trusted-host wxpython.org -f http://wxpython.org/Phoenix/snapshot-builds/'

osname=`uname -s`
uname=`uname -a`

echo " OS NAME: " $osname    $uname


## for Darwin, we can just do install on the fetched binary wheel,
if [[ "$osname" == "Darwin" ]] ; then
    pip install -U $pip_opts $pkgname

elif [[ "$osname" == "Linux" ]] ; then

    ## for Linux, this fetched a source tarball that we now need to build.
    ##
    ## this follows build instructions using Fedora,
    ## which need the following packages installed:
    ##
    ## (sudo dnf/yum install)
    ##     dpkg  python-devel
    ##     webkitgtk webkitgtk-devel
    ##     freeglut freeglut-devel
    ##     libnotify libnotify-devel
    ##     libtiff libtiff-devel
    ##     libjpeg libjpeg-devel
    ##     SDL SDL-devel
    ##     gstreamermm gstreamermm-devel
    echo "PATH " $PATH
    locate dpkg

    sudo /usr/bin/dpkg -i apt*.deb

    sudo apt-get install -y build-essential dpkg-dev
    sudo apt-get install -y aptitude mc

    sudo apt-get install -y libgtk2.0-dev libgtk-3-dev libjpeg-dev libtiff-dev \
  	libsdl1.2-dev libgstreamer-plugins-base0.10-dev \
	libgstreamer-plugins-base1.0-dev \
	libnotify-dev freeglut3 freeglut3-dev libsm-dev \
        libwebkitgtk-dev libwebkitgtk-3.0-dev

    pip download $pip_opts $pkgname

    dirname=`ls | grep wxPython_Phoenix | sed 's/.tar.gz//g'`
    tar xzf $dirname.tar.gz
    cd $dirname

    # custom complier flags and libs from gstreamer:
    export GST_LIBS=`pkg-config gstreamer-0.10 --libs`
    export GST_CFLAGS=`pkg-config gstreamer-0.10 --cflags`

    # we need to make the right sure libiconv is found for wxrc
    python build.py dox etg --nodoc sip
    python build.py build --extra_make='LIBS=-L$CONDA_PREFIX/lib -liconv'
    python build.py build_py
    python setup.py install

    # now copy the libwx* files from site-packages/wx to lib
    cp -pr $SP_DIR/wx/libwx* $CONDA_PREFIX/lib/.
fi
