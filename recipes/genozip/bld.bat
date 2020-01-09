%CC% -Ibzlib -Izlib -D_LARGEFILE64_SOURCE=1 -DVISUAL_C -Wall -O2 base250.c move_to_front.c vcf_header.c zip.c piz.c gloptimize.c buffer.c main.c vcffile.c squeeze.c zfile.c segregate.c profiler.c file.c vb.c dispatcher.c bzlib\blocksort.c bzlib\bzlib.c bzlib\compress.c bzlib\crctable.c bzlib\decompress.c bzlib\huffman.c bzlib\randtable.c zlib\gzlib.c zlib\gzread.c zlib\inflate.c zlib\inffast.c zlib\zutil.c zlib\inftrees.c zlib\crc32.c zlib\adler32.c  -lthreads-win32 -link /OUT genozip.exe

copy genozip.exe %PREFIX%\bin\genozip.exe
copy genozip.exe %PREFIX%\bin\genounzip.exe
copy genozip.exe %PREFIX%\bin\genocat.exe

exit /b 0

rem copy %RECIPE_DIR%\LICENSE.non-commerical.txt %PREFIX%
rem copy %RECIPE_DIR%\LICENSE.commerical.txt %PREFIX%

 
