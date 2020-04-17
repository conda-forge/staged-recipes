FOR /F "delims=" %%i in ('cygpath.exe -u "%PREFIX%"') DO set "pfx=%%i"
REM Download RustUp installer
wget https://win.rustup.rs/x86_64 -o rustup-init.exe
REM Install RustUp
rustup-init.exe -y --default-toolchain nightly
REM Add Rust to the PATH
set PATH=%PATH%;%USERPROFILE%\.cargo\bin
REM Print Rust version
rustc --version
REM Use PEP517 to install the package
pip install -U .

