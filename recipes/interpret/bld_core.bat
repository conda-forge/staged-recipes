Xcopy /E /I shared python\interpret-core\symbolic\shared
cd python/interpret-core
%PYTHON% setup.py build
%PYTHON% setup.py install