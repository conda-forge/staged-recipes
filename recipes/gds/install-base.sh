#!/bin/bash

install_dirs=(
config
Base
Math
Containers
IO/parseline
IO/sockutil
IO/daqsocket
IO/framefast
IO/frameutils
IO/html
IO/jsstack
IO/lmsg
IO/lxr
IO/web
IO/xsil
)

pushd _build
set -ex

# install PConfig.h
make -j ${CPU_COUNT} V=1 VERBOSE=1 install-nodist_includeHEADERS

# install each directory, without any executables
for dir_ in ${install_dirs[@]}; do
    make -j ${CPU_COUNT} V=1 VERBOSE=1 install -C ${dir_} bin_PROGRAMS=""
done

# handle SignalProcessing separately to not recurse
# (see gds-base-crtools)
make -j ${CPU_COUNT} V=1 VERBOSE=1 install -C SignalProcessing bin_PROGRAMS="" SUBDIRS=""
