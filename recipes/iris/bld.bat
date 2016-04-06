set SITECFG=lib/iris/etc/site.cfg
echo [System] > %SITECFG%
echo udunits2_path = %SCRIPTS%\udunits2.dll >> %SITECFG%

rmdir lib\iris\tests\results /s /q
del lib\iris\tests\*.npz

%PYTHON% setup.py install --single-version-externally-managed --record record.txt
