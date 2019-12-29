SHORT_OS_STR=$(uname -s)
if [ "${SHORT_OS_STR:0:5}" == "Linux" ]; then
  make OS=LINUX
else
  make OS=MACOSX
fi
mkdir -p ${PREFIX}/bin
cp teensy_loader_cli ${PREFIX}/bin/.
