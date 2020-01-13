$Env:_CONDA_PKG_BACKUP_DOTNET_HOME = $Env:DOTNET_HOME
$Env:DOTNET_HOME = Join-Path $Env:CONDA_PREFIX "opt/dotnet"
$Env:PATH = $Env:DOTNET_HOME + [System.IO.Path]::PathSeparator + $PATH;
