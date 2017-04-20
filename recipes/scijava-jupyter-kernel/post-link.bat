@echo on

"java.exe" -classpath "%PREFIX%\opt\scijava-jupyter-kernel\jars\*"^
           "org.scijava.jupyter.commands.InstallScijavaKernel" ^
           -pythonBinaryPath "%PREFIX%\python.exe" ^
           -verbose "info" ^
           -classpath "%PREFIX%\opt\scijava-jupyter-kernel\jars\*" ^
           -installAllKernels
