npm install --user "%USERNAME%"  ^
            --python=python2.7   ^
            --loglevel warn      ^
            .
npm start
npm prune --production
del /s /q %PREFIX%\share\man\man1\gulp.1
robocopy build %PREFIX%/static /s /e
:: OS X installs node-gyp globally for some reason which means it ends up in ${PREFIX}
if exist %PREFIX%\lib\node_modules del /s /q %PREFIX%\lib\node_modules
:: Seems some other cruft is left lying around ..
if exist %PREFIX%\build\tmp del /s /q %PREFIX%\build\tmp
