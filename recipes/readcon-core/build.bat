:: Match conda-forge rust example / lol-html: smaller, optimized release artifacts.
if not defined CARGO_PROFILE_RELEASE_STRIP set CARGO_PROFILE_RELEASE_STRIP=symbols
if not defined CARGO_PROFILE_RELEASE_LTO set CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1

cargo auditable cinstall --locked --prefix %LIBRARY_PREFIX% --libdir %LIBRARY_LIB% --library-type cdylib
if errorlevel 1 exit 1
