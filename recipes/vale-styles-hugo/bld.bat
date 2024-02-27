@echo on
robocopy /S "Hugo" "%PREFIX%\share\vale\styles\Hugo" || echo "ok"
dir /S "%PREFIX%\share\vale\styles\Hugo"
