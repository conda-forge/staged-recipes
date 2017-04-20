#!/bin/bash -euo

"${PREFIX}/bin/java" -classpath "${PREFIX}/opt/scijava-jupyter-kernel/jars/*" \
                     "org.scijava.jupyter.commands.InstallScijavaKernel" \
                     -pythonBinaryPath "$(which python)" \
                     -verbose "info" \
                     -classpath "${PREFIX}/opt/scijava-jupyter-kernel/jars/*" \
                     -installAllKernels
