if not exist %PREFIX% mkdir %PREFIX%

rem Directories...
for /D %%i in (.\*) do (
    robocopy /E %%i %PREFIX%\%%i
)

rem Files...
for %%i in (.\*) do (
    if not %%~ni==build_env_setup (
    if not %%~ni==conda_build (
    if not %%~ni==metadata_conda_debug (
        xcopy %%i %PREFIX%
    )
    )
    )
)
