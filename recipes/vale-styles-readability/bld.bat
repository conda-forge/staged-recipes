@echo on
robocopy /S "Readability" "%PREFIX%\share\vale\styles\Readability" || echo "ok"
dir /S "%PREFIX%\share\vale\styles\Readability"
