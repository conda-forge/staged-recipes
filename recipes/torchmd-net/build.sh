if [ ${cuda_compiler_version} == "None" ]; then
    export CPU_ONLY=1
fi

$PYTHON -m pip install . -vv
