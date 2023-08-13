@echo off
setlocal enableextensions enabledelayedexpansion

# Can't figure out why setuptool is putting absolute paths in SOURCES.txt
rename coincurve.egg-info coincurve.egg-info.dist
rename libsecp256k1 libsecp256k1.dist

%PYTHON% -m pip install --use-pep517 . -vv .
if errorlevel 1 exit 1
