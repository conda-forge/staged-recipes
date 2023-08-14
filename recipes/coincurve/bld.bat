@echo off
setlocal enableextensions enabledelayedexpansion

rename coincurve.egg-info coincurve.egg-info.dist
rename libsecp256k1 libsecp256k1.dist

%PYTHON% setup.py install
if errorlevel 1 exit 1
