@echo on

cd ascii
:: the makefiles are only makefile _templates_, but basically functional;
:: to avoid use of perl for mkmf, just execute the template and then
:: do the installation step manually
make FC=flang-new LINKER=lld-link install -f makefile.gf
copy .\x13as_ascii %LIBRARY_BIN%

cd ..\html
make FC=flang-new LINKER=lld-link install -f makefile.gf
copy .\x13as_html %LIBRARY_BIN%
