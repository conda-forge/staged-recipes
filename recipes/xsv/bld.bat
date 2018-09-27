cargo build --release
mkdir %PREFIX%\bin
copy target\release\xsv %PREFIX%\bin
