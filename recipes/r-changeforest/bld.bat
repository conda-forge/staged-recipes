rustup target add x86_64-pc-windows-msvc
"%R%" CMD INSTALL --build changeforest-r
IF %ERRORLEVEL% NEQ 0 exit 1