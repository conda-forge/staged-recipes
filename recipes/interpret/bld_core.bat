Xcopy /E /I shared python\interpret-core\symbolic\shared
cd python/interpret-core
%PYTHON% setup.py build
%PYTHON% -m pip install --no-deps .