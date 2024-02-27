@echo on
robocopy /S "alex" "%PREFIX%\share\vale\styles\alex" || echo "ok"
dir /S "%PREFIX%\share\vale\styles\alex"
