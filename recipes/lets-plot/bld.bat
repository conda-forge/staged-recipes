SET base_url=https://github.com/JetBrains/lets-plot/releases/download/%PROJECT_VERSION%
SET js_package_ditr=js-package\distr\lets-plot.min.js
SET extension_link=%base_url%/winX64Extension.zip
SET js_package_path=js-package\build\dist\js\productionExecutable
SET extension_path=python-extension\build\bin\native\releaseStatic

if not exist %js_package_path% (
    CALL mkdir %js_package_path%
)

if not exist %extension_path% (
    CALL mkdir %extension_path%
)
CALL mkdir temp

CALL cp %js_package_ditr% %js_package_path%
CALL powershell -Command "Invoke-WebRequest -URI %extension_link% -OutFile temp\winX64Extension.zip"
CALL powershell -Command "Expand-Archive -Path temp\winX64Extension.zip -DestinationPath %extension_path%"

CALL cd python-package
CALL %PYTHON% -m pip install . -vv
