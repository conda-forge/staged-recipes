if ($Env:PSModulePath) {
    $Env:_CLOJURE_PSMODULEPATH_BACKUP = "$Env:PSModulePath"
}
$Env:PSModulePath = "%CONDA_PREFIX%\WindowsPowerShell\Modules;" + $Env:PSModulePath

Import-Module ClojureTools

Get-Module -ListAvailable -All | Format-Table -Property Name, Moduletype, Path -Groupby Name
