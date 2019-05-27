if %VS_MAJOR% == 9 (
    COPY C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe .\
    set "PATH=%CD%;%PATH%"
)

%PYTHON% -m pip install . -vv
