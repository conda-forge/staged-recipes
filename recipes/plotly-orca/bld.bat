cmd /c %PREFIX%\npm.cmd config list
rem clear npm install prefix
set NPM_CONFIG_PREFIX=
cmd /c %PREFIX%\npm.cmd config list
cmd /c %PREFIX%\npm.cmd pack
cmd /c %PREFIX%\npm.cmd install -g orca-%PKG_VERSION%.tgz