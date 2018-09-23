set "BINARY_HOME=%PREFIX%\bin"
set "PACKAGE_HOME=%PREFIX%\share\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILDNUM%"
set "STACK_ROOT=%PACKAGE_HOME%\stackroot"

mkdir "%BINARY_HOME%"  || goto :error
mkdir "%PACKAGE_HOME%" || goto :error
mkdir "%STACK_ROOT%"   || goto :error

stack --local-bin-path "%PREFIX%\bin" ^
      --extra-include-dirs "%PREFIX%\include" ^
      --extra-lib-dirs "%PREFIX%\lib" ^
      --stack-root "%STACK_ROOT%" ^
      setup ^
      || goto :error
stack --local-bin-path "%PREFIX%\bin" ^
      --extra-include-dirs "%PREFIX%\include" ^
      --extra-lib-dirs "%PREFIX%\lib" ^
      --stack-root "%STACK_ROOT%" ^
      install --ghc-options ^
        "-optl-pthread -optl-L%PREFIX%\lib" ^
      || goto :error

strip "%PREFIX%\bin\shellcheck.exe" || goto :error

rmdir /S /Q "%PACKAGE_HOME%" || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
