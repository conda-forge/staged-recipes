:: set JCC_JDK=%JAVA_HOME

:: set PATH=%JCC_JDK%\jre\bin\server;%JCC_JDK%;%JCC_JDK%\bin;%JCC_JDK%\lib;%JCC_JDK%\include;%PATH%

:: set JDK_HOME=%JCC_JDK%

:: set

"%PYTHON%" -m jcc  ^
--use_full_names ^
--python orekit ^
--version 9.0 ^
--jar %SRC_DIR%\orekit-conda-recipe\orekit-9.0.jar ^
--jar %SRC_DIR%\orekit-conda-recipe\hipparchus-core-1.1.jar ^
--jar %SRC_DIR%\orekit-conda-recipe\hipparchus-fitting-1.1.jar ^
--jar %SRC_DIR%\orekit-conda-recipe\hipparchus-geometry-1.1.jar ^
--jar %SRC_DIR%\orekit-conda-recipe\hipparchus-ode-1.1.jar ^
--jar %SRC_DIR%\orekit-conda-recipe\hipparchus-optim-1.1.jar ^
--jar %SRC_DIR%\orekit-conda-recipe\hipparchus-stat-1.1.jar ^
--package java.io ^
--package java.util ^
--package java.text ^
--package org.orekit ^
java.io.BufferedReader ^
java.io.FileInputStream ^
java.io.FileOutputStream ^
java.io.InputStream ^
java.io.InputStreamReader ^
java.io.ObjectInputStream ^
java.io.ObjectOutputStream ^
java.io.PrintStream ^
java.io.StringReader ^
java.io.StringWriter ^
java.lang.System ^
java.text.DecimalFormat ^
java.text.DecimalFormatSymbols ^
java.util.ArrayList  ^
java.util.Arrays  ^
java.util.Collection  ^
java.util.Collections ^
java.util.Date ^
java.util.HashMap ^
java.util.HashSet ^
java.util.List  ^
java.util.Locale ^
java.util.Map ^
java.util.Set ^
java.util.TreeSet ^
--module %SRC_DIR%\orekit-conda-recipe\pyhelpers ^
--reserved INFINITE ^
--reserved ERROR ^
--reserved NAN ^
--reserved OVERFLOW ^
--reserved NO_DATA ^
--reserved min ^
--reserved max ^
--reserved mean ^
--build ^
--install

if errorlevel 1 exit 1

:: Add PATH to anaconda java-jdk / jre

:: echo import os > header.txt
:: echo os.environ["PATH"] = r"%SRC_DIR%\Library\jre\bin\server" + os.pathsep + os.environ["PATH"] >> header.txt


:: IF "%ARCH%"=="32" (
    ::win32 ARCH == 32
::    type %SP_DIR%\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILD_STRING:~0,3%.%PKG_BUILD_STRING:~3,1%-win32.egg\%PKG_NAME%\__init__.py >> header.txt
::    del %SP_DIR%\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILD_STRING:~0,3%.%PKG_BUILD_STRING:~3,1%-win32.egg\%PKG_NAME%\__init__.py
::    del %SP_DIR%\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILD_STRING:~0,3%.%PKG_BUILD_STRING:~3,1%-win32.egg\%PKG_NAME%\__init__.pyc
::    ren header.txt __init__.py
::    move __init__.py %SP_DIR%\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILD_STRING:~0,3%.%PKG_BUILD_STRING:~3,1%-win32.egg\%PKG_NAME%\
::)

::IF "%ARCH%"=="64" (
::    ::amd64
::    type %SP_DIR%\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILD_STRING:~0,3%.%PKG_BUILD_STRING:~3,1%-win-amd64.egg\%PKG_NAME%\__init__.py >> header.txt
::    del %SP_DIR%\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILD_STRING:~0,3%.%PKG_BUILD_STRING:~3,1%-win-amd64.egg\%PKG_NAME%\__init__.py
::    del %SP_DIR%\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILD_STRING:~0,3%.%PKG_BUILD_STRING:~3,1%-win-amd64.egg\%PKG_NAME%\__init__.pyc
::    ren header.txt __init__.py
::    move __init__.py %SP_DIR%\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILD_STRING:~0,3%.%PKG_BUILD_STRING:~3,1%-win-amd64.egg\%PKG_NAME%\
:: )

:: See
:: http://docs.continuum.io/conda/build.html
:: for a list of environment variables that are set during the build process.

::amd64
::type %SP_DIR%\orekit-7.0.0-py2.7-win-amd64.egg\orekit\__init__.py >> header.txt
::del %SP_DIR%\orekit-7.0.0-py2.7-win-win32.egg\orekit\__init__.py
::del %SP_DIR%\orekit-7.0.0-py2.7-win-win32.egg\orekit\__init__.pyc
::ren header.txt __init__.py
::move __init__.py %SP_DIR%\orekit-7.0.0-py2.7-win-win32.egg\orekit\
