$smoothingSavedPrefixKey = "_SMOOTHING_LIBOMP_PREFIX_$env:CONDA_SHLVL"
if (Test-Path -LiteralPath "Env:$smoothingSavedPrefixKey") {
    $env:LIBOMP_PREFIX = (Get-Item -LiteralPath "Env:$smoothingSavedPrefixKey").Value
    Remove-Item -LiteralPath "Env:$smoothingSavedPrefixKey"
} else {
    Remove-Item -LiteralPath Env:LIBOMP_PREFIX -ErrorAction SilentlyContinue
}
Remove-Variable smoothingSavedPrefixKey
