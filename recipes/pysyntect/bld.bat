REM Download RustUp installer
Powershell -Command "(New-Object Net.WebClient).DownloadFile('https://win.rustup.rs/x86_64','rustup-init.exe')"
REM wget https://win.rustup.rs/x86_64 -o rustup-init.exe
REM Install RustUp
rustup-init.exe -y --default-toolchain nightly
REM Add Rust to the PATH
set PATH=%PATH%;%USERPROFILE%\.cargo\bin;%PREFIX%\bin\llvm-config
REM Enable Rust nightly
rustup default nightly
REM Print Rust version
rustc --version
REM Use PEP517 to install the package
REM pip install -U . --no-build-isolation
maturin build --release -i %PYTHON%
REM Uninstall Rust
rustup self uninstall -y
REM Install wheel
cd target/wheels
REM set UTF-8 mode by default
chcp 65001
set PYTHONUTF8=1
set PYTHONIOENCODING="UTF-8"
mkdir tmpbuild_%PY_VER%
set TEMP=%CD%\tmpbuild_%PY_VER%
FOR %%w in (*.whl) DO pip install %%w --build tmpbuild_%PY_VER%
