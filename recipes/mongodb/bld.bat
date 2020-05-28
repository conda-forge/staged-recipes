@echo ON
setlocal ENABLEDELAYEDEXPANSION

set "_scons_xtra_flags="
set "_scons_xtra_flags=--dbg=off"
set "_scons_xtra_flags=%_scons_xtra_flags% --disable-warnings-as-errors"
set "_scons_xtra_flags=%_scons_xtra_flags% --enable-free-mon=on"
set "_scons_xtra_flags=%_scons_xtra_flags% --enable-http-client=on"
set "_scons_xtra_flags=%_scons_xtra_flags% --link-model=object"
set "_scons_xtra_flags=%_scons_xtra_flags% --mmapv1=on"
set "_scons_xtra_flags=%_scons_xtra_flags% --mobile-se=on"
set "_scons_xtra_flags=%_scons_xtra_flags% --opt=on"
set "_scons_xtra_flags=%_scons_xtra_flags% --prefix=%LIBRARY_PREFIX%"
set "_scons_xtra_flags=%_scons_xtra_flags% --release"
set "_scons_xtra_flags=%_scons_xtra_flags% --server-js=on"
set "_scons_xtra_flags=%_scons_xtra_flags% --ssl=on --ssl-provider=openssl"
set "_scons_xtra_flags=%_scons_xtra_flags% --wiredtiger=on"
set "_scons_xtra_flags=%_scons_xtra_flags% VERBOSE=on"

for %%v in (boost icu pcre sqlite snappy yaml zlib zstd abseil-cpp) do (
 set "_scons_xtra_flags=!_scons_xtra_flags! --use-system-%%v"
)

set "_scons_xtra_flags=%_scons_xtra_flags% CCFLAGS=/I%LIBRARY_INC%"
set "_scons_xtra_flags=%_scons_xtra_flags% CXXFLAGS=/I%LIBRARY_INC%"
set "_scons_xtra_flags=%_scons_xtra_flags% LINKFLAGS=/LIBPATH:%LIBRARY_LIB%"
set "_scons_xtra_flags=%_scons_xtra_flags% CPPDEFINES=BOOST_ALL_DYN_LINK"

%PYTHON% buildscripts/scons.py install core %_scons_xtra_flags%
