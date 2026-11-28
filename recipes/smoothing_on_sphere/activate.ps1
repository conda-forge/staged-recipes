$smoothingSavedPrefixKey = "_SMOOTHING_LIBOMP_PREFIX_$env:CONDA_SHLVL"
if (Test-Path -LiteralPath Env:LIBOMP_PREFIX) {
    Set-Item -LiteralPath "Env:$smoothingSavedPrefixKey" -Value $env:LIBOMP_PREFIX
} else {
    Remove-Item -LiteralPath "Env:$smoothingSavedPrefixKey" -ErrorAction SilentlyContinue
}
$env:LIBOMP_PREFIX = Join-Path $env:CONDA_PREFIX 'Library'
Remove-Variable smoothingSavedPrefixKey
