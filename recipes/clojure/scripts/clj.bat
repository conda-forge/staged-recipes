@echo off
@set "PSModulePath"="%CONDA_PREFIX%\WindowsPowerShell\Modules\ClojureTools;%PSModulePath%"
powershell -Command "clj $args" %*
