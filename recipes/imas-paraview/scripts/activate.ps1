$py = Join-Path $env:CONDA_PREFIX 'python.exe'
$helper = Join-Path $env:CONDA_PREFIX 'etc/conda/imas-paraview-pvpath.py'
if ((Test-Path -LiteralPath $py) -and (Test-Path -LiteralPath $helper)) {
    & $py $helper contains 2>$null
    if ($LASTEXITCODE -eq 1) {
        $newValue = & $py $helper add
        if ($LASTEXITCODE -eq 0) {
            $key = & $py $helper key
            if ($LASTEXITCODE -eq 0) {
                $env:PV_PLUGIN_PATH = $newValue
                Set-Item -LiteralPath "Env:$key" -Value '1'
            }
        }
    }
}
Remove-Variable py, helper, newValue, key -ErrorAction SilentlyContinue
