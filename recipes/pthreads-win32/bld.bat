set "XCFLAGS=/W3 /MT /nologo"

cd pthreads.2
nmake /E clean VSE-inlined

copy pthreadVSE2.lib %LIBRARY_LIB%\pthreads.lib
copy pthreadVSE2.dll %LIBRARY_BIN%\pthreadVSE2.dll

copy pthread.h %LIBRARY_INC%\pthread.h
copy sched.h %LIBRARY_INC%\sched.h
copy semaphore.h %LIBRARY_INC%\semaphore.h

nmake /E clean VC-static
copy pthreadVC2.lib %LIBRARY_LIB%\pthreads_static.lib

cd tests
set "CFLAGS=%XCFLAGS%"
