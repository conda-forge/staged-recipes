"%PYTHON%" -m pip install src/ -vv

mkdir -p %PREFIX%/bin

copy src\eodie_process.py %PREFIX%\bin\eodie_process.py
