@echo on

set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig"

for /f "usebackq tokens=*" %%a in (`pkg-config --cflags libpeas-1.0`) do set "PC_CFLAGS=%%a"

set "PC_LIBS=peas-1.0.lib gio-2.0.lib intl.lib iconv.lib shlwapi.lib dnsapi.lib iphlpapi.lib ws2_32.lib gmodule-2.0.lib intl.lib iconv.lib z.lib girepository-1.0.lib gobject-2.0.lib intl.lib iconv.lib ffi.lib glib-2.0.lib intl.lib iconv.lib pcre.lib ws2_32.lib winmm.lib"

%CC% %PC_CFLAGS% "/c" %RECIPE_DIR%\test.c
link /out:test.exe /MACHINE:x64 test.obj /LIBPATH:%LIBRARY_LIB% %PC_LIBS%
test


