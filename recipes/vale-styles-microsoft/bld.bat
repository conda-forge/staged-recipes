@echo on
robocopy /S "Microsoft" "%PREFIX%\share\vale\styles\Microsoft" || echo "ok"
dir /S "%PREFIX%\share\vale\styles\Microsoft"
