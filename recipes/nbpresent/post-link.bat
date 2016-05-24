"%PREFIX%\Scripts\jupyter-nbextension.exe" enable nbpresent --py --sys-prefix && "%PREFIX%\Scripts\jupyter-serverextension.exe" enable --py nbpresent --sys-prefix && if errorlevel 1 exit 1
