@echo off
setlocal EnableDelayedExpansion

for /R clojure-tools %%G in (*) do (
    move /Y "%%G" "%PREFIX%"
)
