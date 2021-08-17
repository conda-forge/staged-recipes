set TEMP=%CD%\tmpbuild_%PY_VER%

cd target/wheels

chcp 65001
set PYTHONUTF8=1
set PYTHONIOENCODING="UTF-8"
FOR %%w in (*.whl) DO %PYTHON% -m pip install %%w --build tmpbuild_%PY_VER%
