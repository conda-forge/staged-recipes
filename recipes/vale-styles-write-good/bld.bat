@echo on
robocopy /S "write-good" "%PREFIX%\share\vale\styles\write-good" || echo "ok"
dir /S "%PREFIX%\share\vale\styles\write-good"
