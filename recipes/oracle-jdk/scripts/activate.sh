export JAVA_HOME_CONDA_BACKUP=$JAVA_HOME
export JAVA_HOME=$CONDA_PREFIX

export JAVA_LD_LIBRARY_PATH_BACKUP=$JAVA_LD_LIBRARY_PATH

os=$(uname -s | tr '[:upper:]' '[:lower:]')
if [ $os == 'darwin' ]; then
    export JAVA_LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/server
else
    export JAVA_LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/amd64/server
fi

