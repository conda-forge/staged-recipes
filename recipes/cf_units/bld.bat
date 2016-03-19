set SITECFG=cf_units/etc/site.cfg
echo [System] > %SITECFG%
echo udunits2_path = %SCRIPTS%\udunits2.dll >> %SITECFG%


"%PYTHON%" setup.py install --single-version-externally-managed  --record record.txt
if errorlevel 1 exit 1
