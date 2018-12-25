SET PROJ_DIR=apr
SET PROJ_LIB=!PROJ_DIR:-=!

copy !PROJ_DIR!\%SHARED_LIBDIR%\lib!PROJ_LIB!-1.dll %LIBRARY_BIN%\
copy !PROJ_DIR!\%SHARED_LIBDIR%\lib!PROJ_LIB!-1.lib %LIBRARY_LIB%\
IF EXIST !PROJ_DIR!\%SHARED_LIBDIR%\lib!PROJ_LIB!-1.pdb copy !PROJ_DIR!\%SHARED_LIBDIR%\lib!PROJ_LIB!-1.pdb %LIBRARY_BIN%\

copy !PROJ_DIR!\%STATIC_LIBDIR%\!PROJ_LIB!-1.lib %LIBRARY_PREFIX%\LibR\
IF EXIST !PROJ_DIR!\%STATIC_LIBDIR%\!PROJ_LIB!-1.pdb copy !PROJ_DIR!\%STATIC_LIBDIR%\!PROJ_LIB!-1.pdb %LIBRARY_PREFIX%\LibR\

xcopy !PROJ_DIR!\include\*.h %LIBRARY_INC%\

mkdir %LIBRARY_INC%\arch\win32

copy apr\include\arch\apr_private_common.h %LIBRARY_INC%\arch\
xcopy apr\include\arch\win32\*.h %LIBRARY_INC%\arch\win32\
