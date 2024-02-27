@echo on
robocopy /S "Google" "%PREFIX%\share\vale\styles\Google" || echo "ok"
dir /S "%PREFIX%\share\vale\styles\Google"
