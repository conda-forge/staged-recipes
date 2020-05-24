#!/bin/bash

pushd src/debugpy/_vendored/pydevd/pydevd_attach_to_process
rm *.so *.dll *.dylib *.exe *.pdb
pushd linux_and_mac

if [[ "${target_platform}" == "osx-64" ]];
then
    SHARED_LIBRARY="attach_x86_64${SHLIB_EXT}"
    EXTRA_FLAGS="-dynamiclib -lc -nostartfiles"
else
    SHARED_LIBRARY="attach_linux_amd64${SHLIB_EXT}"
    EXTRA_FLAGS="-shared -nostartfiles"
fi

${CXX} ${CXXFLAGS} ${EXTRA_FLAGS} -o ${SHARED_LIBRARY} attach.cpp
mv ${SHARED_LIBRARY} ../
popd
popd
${PYTHON} -m pip install . -vv
