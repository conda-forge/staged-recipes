echo. > config.h

echo. > unistd.h

cl.exe /c lzf_c.c lzf_d.c
lib lzf_c.obj lzf_d.obj /out:lzf_static.lib

mkdir "%PREFIX%\Library\bin" "%PREFIX%\Library\lib" "%PREFIX%\Library\include"
copy lzf_static.lib "%PREFIX%\Library\lib"
copy lzf.h "%PREFIX%\Library\include"
