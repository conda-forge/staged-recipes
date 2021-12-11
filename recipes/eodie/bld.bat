cd src
"%PYTHON%" -m pip install . --no-deps --ignore-installed -vvv
cd ..
mkdir "%PREFIX%\bin"
COPY  src\eodie_process.py "%PREFIX%\bin\eodie_process.py"
