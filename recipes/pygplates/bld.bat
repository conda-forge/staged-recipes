set BUILD_TYPE=Release

:: Configure pyGPlates.
::
:: Note that CMAKE_BUILD_TYPE is ignored for multi-configuration tools (eg, Visual Studio).
:: Note that CMAKE_INSTALL_PREFIX refers to Python's site-packages location.
:: Note that Boost_ROOT helps avoid finding the Boost library using inherited env var PATH
::      (which can reference a Boost outside of conda). Also, CGAL looks for Boost too.
cmake -G "%CMAKE_GENERATOR%" ^
      -D CMAKE_BUILD_TYPE=%BUILD_TYPE% ^
      -D GPLATES_BUILD_GPLATES:BOOL=FALSE ^
      -D GPLATES_INSTALL_STANDALONE:BOOL=FALSE ^
      -D "CMAKE_PREFIX_PATH:PATH=%PREFIX%;%LIBRARY_PREFIX%" ^
      -D "CMAKE_INSTALL_PREFIX:PATH=%SP_DIR%" ^
      -D "Boost_ROOT:PATH=%LIBRARY_PREFIX%" ^
      "%SRC_DIR%"
if errorlevel 1 exit 1

:: Compile pyGPlates.
::
:: Note that '--config' is only used by multi-configuration tools (eg, Visual Studio).
cmake --build . --config %BUILD_TYPE% --target install-into-python
if errorlevel 1 exit 1
