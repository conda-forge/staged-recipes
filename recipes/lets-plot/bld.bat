SET base_url=https://github.com/JetBrains/lets-plot/releases/download/%PROJECT_VERSION%
SET js_package_distr=js-package\distr\lets-plot.min.js
SET extension_link=%base_url%/winX64Extension.zip
SET js_package_path=js-package\build\dist\js\productionExecutable
SET extension_path=python-extension\build\bin\native\releaseStatic

for /f "tokens=*" %%i in ('%PYTHON% -c "from sysconfig import get_paths as gp; print(gp()['scripts'])"') do set py_bin_path=%%i
for /f "tokens=*" %%i in ('%PYTHON% -c  "from sysconfig import get_paths as gp; print(gp()['include'])"') do set py_include_path=%%i
for /f "tokens=*" %%i in ('%PYTHON% -c  "import platform; print(platform.machine())"') do set py_architecture=%%i

if not exist %js_package_path% (
    CALL mkdir %js_package_path%
)

if not exist %extension_path% (
    CALL .\gradlew.bat -Pbuild_release=true -Ppython.bin_path=%py_bin_path% -Ppython.include_path=%py_include_path% -Penable_python_package=true -Parchitecture=%py_architecture%
)
CALL mkdir temp

CALL copy %js_package_distr% %js_package_path%

CALL cd python-package
CALL %PYTHON% -m pip install . -vv
