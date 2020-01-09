cl.exe /D_LARGEFILE64_SOURCE=1 /O2 -Tp base250.c -Tp move_to_front.c -Tp vcf_header.c -Tp zip.c -Tp piz.c -Tp gloptimize.c -Tp buffer.c -Tp main.c -Tp vcffile.c -Tp squeeze.c -Tp zfile.c -Tp segregate.c -Tp profiler.c -Tp file.c -Tp vb.c -Tp dispatcher.c -Tp compatability\mac_gettime.c -Tp compatability\win32_pthread.c -Tp compatability\visual_c_gettime.c  -Tc bzlib\blocksort.c -Tc bzlib\bzlib.c -Tc bzlib\compress.c -Tc bzlib\crctable.c -Tc bzlib\decompress.c -Tc bzlib\huffman.c -Tc bzlib\randtable.c -Tc zlib\gzlib.c -Tc zlib\gzread.c -Tc zlib\inflate.c -Tc zlib\inffast.c -Tc zlib\zutil.c -Tc zlib\inftrees.c -Tc zlib\crc32.c -Tc zlib\adler32.c  /link pthread-win32.lib /OUT genozip.exe

copy genozip.exe %PREFIX%\bin\genozip.exe
copy genozip.exe %PREFIX%\bin\genounzip.exe
copy genozip.exe %PREFIX%\bin\genocat.exe

exit /b 0

rem copy %RECIPE_DIR%\LICENSE.non-commerical.txt %PREFIX%
rem copy %RECIPE_DIR%\LICENSE.commerical.txt %PREFIX%

 
