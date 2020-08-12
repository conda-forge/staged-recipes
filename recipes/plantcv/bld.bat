@powershell -command "(get-content requirements.txt) | foreach-object {$_ -replace 'opencv.*', ''} | set-content requirements.txt"
for /f %%i in ('python -c "import versioneer; print(versioneer.get_version())"') do set version=%%i
@powershell -command "(get-content setup.py) | foreach-object {$_ -replace 'versioneer.get_version\(\)', '\"%version%\"'} | set-content setup.py"
@powershell -command "(get-content setup.py) | foreach-object {$_ -replace 'cmdclass=versioneer.get_cmdclass\(\),', ''} | set-content setup.py"
@powershell -command "(get-content setup.py) | foreach-object {$_ -replace 'setup_requires=\[\"pytest-runner\"\],', ''} | set-content setup.py"
@powershell -command "(get-content setup.py) | foreach-object {$_ -replace 'tests_require=\[''pytest''\],', ''} | set-content setup.py"
python -m pip install . --no-deps -vv
