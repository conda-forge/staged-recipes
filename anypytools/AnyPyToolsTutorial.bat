@echo off
cd %~f0\..\..\share\notebooks\anypytools
"%~f0\..\jupyter.exe" "notebook" "--notebook-dir=." "00_AnyPyTools_tutorial.ipynb" %*
