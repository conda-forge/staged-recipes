@echo on

cargo fix --lib -p cargo-make --allow-no-vcs
if errorlevel 1 exit 1

cargo install --path . --root %PREFIX% --locked
if errorlevel 1 exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1
