@echo on

set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig"
set "GIO_MODULE_DIR="
set "G_MESSAGES_DEBUG=all"

for /f "usebackq tokens=*" %%a in (`pkg-config --cflags libsoup-2.4`) do set "PC_CFLAGS=%%a"

set "PC_LIBS=soup-2.4.lib sqlite3.lib ws2_32.lib xml2.lib iconv.lib z.lib psl.lib ws2_32.lib icuuc.lib icudt.lib brotlidec.lib brotlicommon.lib gio-2.0.lib intl.lib iconv.lib shlwapi.lib dnsapi.lib iphlpapi.lib ws2_32.lib gmodule-2.0.lib intl.lib iconv.lib z.lib gobject-2.0.lib intl.lib iconv.lib libffi.lib glib-2.0.lib intl.lib iconv.lib pcre.lib ws2_32.lib winmm.lib"

%CC% %PC_CFLAGS% "/c" %RECIPE_DIR%\test.c
link /out:test.exe /MACHINE:x64 test.obj /LIBPATH:%LIBRARY_LIB% %PC_LIBS%
test


