@if defined PSModulePath {
     @set "_CLOJURE_PSMODULEPATH_BACKUP"="%PSModulePath%"
}
@set "PSModulePath"="%PREFIX%\WindowsPowerShell\Modules\ClojureTools;%PSModulePath%"
