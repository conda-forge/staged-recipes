mkdir %PREFIX%/fonts
for %%f in (*.ttf) do (
    copy %%~nf %PREFIX%/fonts/%%~nf
)
