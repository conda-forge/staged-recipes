if %VS_MAJOR% == 9 (
    set "PATH=C:\Windows\Microsoft.NET\Framework\v4.0.30319;%PATH%"
)

%PYTHON% -m pip install . -vv
