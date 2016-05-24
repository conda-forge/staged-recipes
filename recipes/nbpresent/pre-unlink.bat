"%PREFIX%\Scripts\jupyter-nbextension" disable nbpresent --py --sys-prefix && "%PREFIX%\Scripts\jupyter-serverextension" disable nbpresent --py --sys-prefix && if errorlevel 1 exit 1
