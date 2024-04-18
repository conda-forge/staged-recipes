@if defined PSModulePath (
     @set "_CLOJURE_PSMODULEPATH_BACKUP=%PSModulePath%"
)
@set "PATH=%PREFIX%\Scripts;%PATH%"
