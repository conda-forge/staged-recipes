cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo build --release
MKDIR %PREFIX%\bin
MOVE target\release\vivid.exe %PREFIX%\bin\vivid.exe
