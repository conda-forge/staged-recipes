#!/usr/bin/env bash

RCFILE=$(dirname ${BASH_SOURCE[0]})/resources.rc
test -f ${RCFILE} && rm -f ${RCFILE}
echo "#include \"winuser.h\""      > ${RCFILE}
echo "1 RT_MANIFEST manifest.xml" >> ${RCFILE}
_ARCH=64  # TODO: Adjust for win-arm64
for _ARCH in 64 32; do
  test -f resources-${_ARCH}.res && rm -f resources-${_ARCH}.res
  windres --input ${RCFILE} --output resources-${_ARCH}.res --output-format=coff
  for _TYPE in cli gui; do
    if [[ ${_TYPE} == cli ]]; then
      CPPFLAGS=
      LDFLAGS=
    else
      CPPFLAGS="-D_WINDOWS -mwindows"
      LDFLAGS="-mwindows"
    fi
    # You *could* use MSVC 2008 here, but you'd end up with much larger (~230k) executables.
    # cl.exe -opt:nowin98 -D NDEBUG -D "GUI=0" -D "WIN32_LEAN_AND_MEAN" -ZI -Gy -MT -MERGE launcher.c -Os -link -MACHINE:x64 -SUBSYSTEM:CONSOLE version.lib advapi32.lib shell32.lib
    ${CC} -O2 -DSCRIPT_WRAPPER -DUNICODE -D_UNICODE -DMINGW_HAS_SECURE_API ${CPPFLAGS} launcher.c -c -o ${_TYPE}-${_ARCH}.o
    ${CC} -Wl,-s --static -static-libgcc -municode ${LDFLAGS} ${_TYPE}-${_ARCH}.o resources-${_ARCH}.res -o ${_TYPE}-${_ARCH}.exe
  done
done
ls -alh *.exe
mv *.exe %{PREFIX}/Scripts
# Set PYLAUNCH_DEBUG=1 to debug in CMD.exe
