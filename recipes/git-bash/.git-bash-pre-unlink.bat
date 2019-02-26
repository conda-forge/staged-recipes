rmdir /s /q "%PREFIX%\Library\git-bash\dev" 2>nul || cd .
rmdir /s /q "%PREFIX%\Library\git-bash\etc" 2>nul || cd .
del "%PREFIX%\Library\git-bash\mingw64\libexec\git-core\dlls-copied.exe" 2>nul || cd .
rmdir /s /q "%PREFIX%\Library\git-bash" 2>nul || cd .
