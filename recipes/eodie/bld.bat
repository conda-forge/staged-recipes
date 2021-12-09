"%PYTHON%" -m pip install src -vv
mkdir "%PREFIX%\bin"
COPY  src\eodie_process.py "%PREFIX%\bin\eodie_process.py"
