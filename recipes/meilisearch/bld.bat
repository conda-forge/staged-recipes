cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo build --release --locked

MKDIR %LIBRARY_PREFIX%\bin

MOVE target\release\meilisearch.exe %LIBRARY_PREFIX%\bin\meilisearch.exe