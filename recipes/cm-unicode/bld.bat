mkdir %PREFIX%/fonts
for %%f in (*.ttf) do (
    copy %%f %PREFIX%/fonts/%%f
)
