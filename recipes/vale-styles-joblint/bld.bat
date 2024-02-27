@echo on
robocopy /S "Joblint" "%PREFIX%\share\vale\styles\Joblint" || echo "ok"
dir /S "%PREFIX%\share\vale\styles\Joblint"
