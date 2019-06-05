mkdir %PREFIX%\fonts
for %%f in (*.ttf) do (
    copy %%~nxf %PREFIX%\fonts\%%~nxf
)
