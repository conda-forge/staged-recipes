@echo off
cd %~f0\..\..\AnyPyToolsTutorial
"%~f0\..\ipython.exe" "notebook" "--notebook-dir=." "00_AnyPyTools_tutorial.ipynb" %*
