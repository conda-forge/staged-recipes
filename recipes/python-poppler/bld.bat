set "CC=clang-cl"
set "CXX=clang-cl"

where lld-link

python -m pip install . -vv --no-deps --no-build-isolation -Cbuilddir=builddir -Csetup-args=-Dbuildtype=debug
type builddir\meson-logs\meson-log.txt