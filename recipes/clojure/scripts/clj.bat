@echo off
powershell Register-PSRepository -Name ClojureTools -SourceLocation "%CONDA_PREFIX%\WindowsPowerShell\Modules\ClojureTools" -InstallationPolicy Trusted
powershell -Command "clj $args" %*
