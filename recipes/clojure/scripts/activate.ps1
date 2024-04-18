if ($Env:PSModulePath) {
    $Env:_CLOJURE_PSMODULEPATH_BACKUP = "$Env:PSModulePath"
}
$Env:PSModulePath = $Env:CONDA_PREFIX + "\WindowsPowerShell\Modules;" + $Env:PSModulePath
$Env:PSModulePath = $Env:PREFIX + "\WindowsPowerShell\Modules;" + $Env:PSModulePath

Invoke-Expression -Command "echo Activated ClojureTools from $Env:CONDA_PREFIX"
Invoke-Expression -Command "echo Activated ClojureTools from $Env:PREFIX"
Invoke-Expression -Command "echo Activated ClojureTools from $Env:PSModulePath"

Import-Module ClojureTools

Get-Module -ListAvailable -All | Format-Table -Property Name, Moduletype, Path -Groupby Name
