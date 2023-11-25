cargo install --root "%LIBRARY_PREFIX%" --path . 

strip "%LIBRARY_PREFIX%\bin\nbwipers.exe"

del /F /Q "%LIBRARY_PREFIX%\.crates.toml"