echo. > config.h

echo. > unistd.h

cl.exe /c lzf_c.c lzf_d.c
lib lzf_c.obj lzf_d.obj /out:lzf_static.lib

copy lzf_static.lib "%LIBRARY_LIB%"
copy lzf.h "%LIBRARY_INC%"
