@echo off
@set PSModulePath="%CONDA_PREFIX%\WindowsPowerShell\Modules\ClojureTools;%PSModulePath%"
C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe -Command "clojure $args" %*
