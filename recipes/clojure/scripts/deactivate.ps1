Remove-Module -Name clojure -Force -ErrorAction SilentlyContinue

if ($Env:_CLOJURE_PSMODULEPATH_BACKUP) {
  $Env:PSModulePath = "$Env:_CLOJURE_PSMODULEPATH_BACKUP"
  $Env:_CLOJURE_PSMODULEPATH_BACKUP = ""
}