cd python

set "HOST_PYTHON=%PYTHON:\=/%"
set "CMAKE_GENERATOR=Ninja"
set "CMAKE_ARGS=-DPython3_EXECUTABLE:FILEPATH=%HOST_PYTHON% %CMAKE_ARGS%"
%PYTHON% -m pip install -v --no-build-isolation .
