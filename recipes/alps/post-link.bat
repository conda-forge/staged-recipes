@echo off
if "%PREFIX%" == "%CONDA_PREFIX%" (
	@echo.  >> "%PREFIX%\.messages.txt"
	@echo ALPS has been installed in the current enviroment. To set the enviroment variables correctly you should start a new Conda prompt or execute the following command: >> "%PREFIX%\.messages.txt"
	@echo call "%PREFIX%\etc\conda\activate.d\alps_vars.bat" >> "%PREFIX%\.messages.txt"
)