cargo build --release
MKDIR %PREFIX%\bin
MOVE target\release\lsd.exe %PREFIX%\bin\lsd.exe
