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

export PATH_TYPE=MONO_PATH
if [ -z ${MONO_PATH} ]; then
    export MONO_PATH=$CONDA_PREFIX/lib
else
    export CS_OLD_MONO_PATH=$MONO_PATH
    appendToPath $CONDA_PREFIX/lib
fi