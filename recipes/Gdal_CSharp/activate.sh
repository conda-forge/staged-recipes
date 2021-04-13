checkPath () {
        case ":${!PATH_TYPE}:" in
                *":$1:"*) return 1
                        ;;
        esac
        return 0;
}

# Prepend to $PATH
prependToPath () {
        for a; do
                checkPath $a
                if [ $? -eq 0 ]; then
                        export ${PATH_TYPE}=$a:${!PATH_TYPE}
                fi
        done
}

# Append to $PATH
appendToPath () {
        for a; do
                checkPath $a
                if [ $? -eq 0 ]; then
                        export ${PATH_TYPE}=${!PATH_TYPE}:$a
                fi
        done
}

if [[ $target_platform =~ linux.* ]]; then
    export PATH_TYPE=DYLD_LIBRARY_PATH
    if [ -z ${LD_LIBRARY_PATH} ]; then
        export LD_LIBRARY_PATH=/usr/lib:$CONDA_PREFIX/lib
    else
        prependToPath /usr/lib
        appendToPath $CONDA_PREFIX/lib
    fi
    export PATH_TYPE=MONO_PATH
    if [ -z ${MONO_PATH} ]; then
        export MONO_PATH=$CONDA_PREFIX/lib
    else
        appendToPath $CONDA_PREFIX/lib
    fi
else
    export PATH_TYPE=DYLD_LIBRARY_PATH
    if [ -z ${DYLD_LIBRARY_PATH} ]; then
        export DYLD_LIBRARY_PATH=/usr/lib:$CONDA_PREFIX/lib
    else
        prependToPath /usr/lib
        appendToPath $CONDA_PREFIX/lib
    fi
    export PATH_TYPE=MONO_PATH
    if [ -z ${MONO_PATH} ]; then
        export MONO_PATH=$CONDA_PREFIX/lib
    else
        appendToPath $CONDA_PREFIX/lib
    fi
fi
