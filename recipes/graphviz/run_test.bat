for %%t in (png, pdf, svg) do (
    dot -T%%t -o sample.%%t sample.dot
    if errorlevel 1 exit 1
)
