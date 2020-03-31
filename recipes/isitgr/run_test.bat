set CHERE_INVOKING=1
bash -lc "./run_test.sh"
if errorlevel 1 exit 1
exit 0
