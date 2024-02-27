@echo on
robocopy /S "proselint" "%PREFIX%\share\vale\styles\proselint" || echo "ok"
dir /S "%PREFIX%\share\vale\styles\proselint"
