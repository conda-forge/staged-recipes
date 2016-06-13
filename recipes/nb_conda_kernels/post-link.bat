@echo off
1>>"%PREFIX%\.messages.txt" 2>&1 (
  "%PREFIX%\python.exe" -m nb_conda_kernels.install --enable --prefix="%PREFIX%"
)
