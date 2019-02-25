rmdir /s /q "%PREFIX%\Library\git-bash\dev" || cd "%CD%"
rmdir /s /q "%PREFIX%\Library\git-bash\etc" || cd "%CD%"
del "%PREFIX%\Library\git-bash\mingw64\libexec\git-core\dlls-copied.exe" || cd "%CD%"
rmdir /s /q "%PREFIX%\Library\git-bash" || cd "%CD%"
