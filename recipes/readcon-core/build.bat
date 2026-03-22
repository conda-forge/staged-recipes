cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1

cargo build --release
if errorlevel 1 exit 1

mkdir %LIBRARY_LIB%
copy target\release\readcon_core.lib %LIBRARY_LIB%\
if errorlevel 1 exit 1

mkdir %LIBRARY_INC%
copy include\readcon-core.h %LIBRARY_INC%\
copy include\readcon-core.hpp %LIBRARY_INC%\
if errorlevel 1 exit 1
