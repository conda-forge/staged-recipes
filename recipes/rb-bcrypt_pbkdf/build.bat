set GEM_NAME=%PKG_NAME:rb-=%
call gem install --norc -l -V --ignore-dependencies %GEM_NAME%-%PKG_VERSION%.gem
if errorlevel 1 exit 1
call gem unpack %GEM_NAME%-%PKG_VERSION%.gem
if errorlevel 1 exit 1
