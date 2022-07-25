MKDIR %PREFIX%\Scripts
COPY sass.bat %PREFIX%\Scripts
XCOPY /e /i src %PREFIX%\Scripts\src
