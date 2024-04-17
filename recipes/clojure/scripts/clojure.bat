@echo off
@set PSModulePath="%CONDA_PREFIX%\WindowsPowerShell\Modules\ClojureTools;%PSModulePath%"
powershell -Command "clojure $args" %*
