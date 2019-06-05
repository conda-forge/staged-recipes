mkdir %PREFIX%\fonts
for %%f in (*.ttf) do (
    copy %%~nx %PREFIX%\fonts\%%~nx
)
