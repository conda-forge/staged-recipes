cargo build --release --locked --features tls-vendored
MKDIR %PREFIX%\bin
MOVE target\release\starship.exe %PREFIX%\bin\starship.exe
