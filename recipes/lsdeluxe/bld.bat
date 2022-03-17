cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo build --release
MKDIR %PREFIX%\bin
MOVE target\release\lsd.exe %PREFIX%\bin\lsd.exe
