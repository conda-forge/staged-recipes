:: Nasty hack to force the newer MSBuild from .NET is still used for the older
:: Visual Studio build. Without this an older MSBuild will be picked up by accident on
:: AppVeyor after running `vcvars32.bat`, which fails to process our solution files.
::
:: ref: https://github.com/conda-forge/staged-recipes/pull/194#issuecomment-203577297
:: ref: https://github.com/conda-forge/libsodium-feedstock/commit/b411740e0f439d5a5d257f74f74945f86585684a#diff-d04c86b6bb20341f5f7c53165501a393R12
:: ref: https://stackoverflow.com/q/2709279
::
:: Also there is some bug using MSBuild from .NET to build with VS 2008 64-bit, which
:: we workaround as well.
::
:: ref: https://social.msdn.microsoft.com/Forums/vstudio/en-US/19bb86ab-258a-40a9-b9fc-3bf36cac46bc/team-build-error-msb4018-the-quotresolvevcprojectoutputquot-task-failed-unexpectedly?forum=tfsbuild
if %VS_MAJOR% == 9 (
    set "PATH=C:\Windows\Microsoft.NET\Framework\v4.0.30319;%PATH%"
    set VC_PROJECT_ENGINE_NOT_USING_REGISTRY_FOR_INIT=1
)

%PYTHON% -m pip install . -vv
