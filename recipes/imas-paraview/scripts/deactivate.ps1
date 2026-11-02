$py = Join-Path $env:CONDA_PREFIX 'python.exe'
$helper = Join-Path $env:CONDA_PREFIX 'etc/conda/imas-paraview-pvpath.py'
if ((Test-Path -LiteralPath $py) -and (Test-Path -LiteralPath $helper)) {
    & $py $helper owned 2>$null
    if ($LASTEXITCODE -eq 0) {
        $key = & $py $helper key
        if ($LASTEXITCODE -ne 0) { return }
        $newValue = & $py $helper remove
        if ($LASTEXITCODE -eq 0) {
            if ($newValue) { $env:PV_PLUGIN_PATH = $newValue }
            else { Remove-Item Env:PV_PLUGIN_PATH -ErrorAction SilentlyContinue }
            Remove-Item -LiteralPath "Env:$key" -ErrorAction SilentlyContinue
        }
    }
}
Remove-Variable py, helper, key, newValue -ErrorAction SilentlyContinue
