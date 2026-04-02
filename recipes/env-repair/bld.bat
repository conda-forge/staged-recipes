@echo on

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation

REM noarch python packages must not ship platform-specific .exe launchers
if exist "%PREFIX%\\Scripts\\env-repair.exe" del /f /q "%PREFIX%\\Scripts\\env-repair.exe"
if exist "%PREFIX%\\Scripts\\env-repair.exe.manifest" del /f /q "%PREFIX%\\Scripts\\env-repair.exe.manifest"

REM Provide a Windows-friendly entry point without a binary .exe launcher.
REM cmd.exe will pick up env-repair.bat via PATHEXT when calling `env-repair`.
(
  echo @echo off
  echo python -m env_repair.cli %%*
) > "%PREFIX%\\Scripts\\env-repair.bat"
