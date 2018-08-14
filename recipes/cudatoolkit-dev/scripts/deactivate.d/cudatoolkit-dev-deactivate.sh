#!/usr/bin/env bash

remove_symlink_linux() {

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/bin/*;
        do  
            to_unlink=$(basename ${f});
            
            if [ -L "$CONDA_PREFIX/bin/${to_unlink}" ]; then
                unlink $CONDA_PREFIX/bin/${to_unlink};
            fi 

        done


        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/lib64/*;
        do  
            to_unlink=$(basename ${f});

            if [ -L "$CONDA_PREFIX/lib/${to_unlink}" ]; then
            unlink $CONDA_PREFIX/lib/${to_unlink};
            fi 
            
        done


        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm/bin/*;
        do  
            to_unlink=$(basename ${f});

            if [ -L "$CONDA_PREFIX/bin/${to_unlink}" ]; then
            unlink $CONDA_PREFIX/bin/${to_unlink};
            fi 
            
        done

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm/lib64/*;
        do  
            to_unlink=$(basename ${f});

            if [ -L "$CONDA_PREFIX/lib/${to_unlink}" ]; then
            unlink $CONDA_PREFIX/lib/${to_unlink};
            fi 
            
        done

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm/libdevice/*;
        do  
            to_unlink=$(basename ${f});

            if [ -L "$CONDA_PREFIX/lib/${to_unlink}" ]; then
            unlink $CONDA_PREFIX/lib/${to_unlink};
            fi 
            
        done

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/include/*;
        do 
            to_unlink=$(basename ${f});

            if [ -L "$CONDA_PREFIX/include/${to_unlink}" ]; then
            unlink $CONDA_PREFIX/include/${to_unlink};
            fi 
        done    
}


remove_symlink_osx() {

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/bin/*;
        do  
            to_unlink=$(basename ${f});
            
            if [ -L "$CONDA_PREFIX/bin/${to_unlink}" ]; then
                unlink $CONDA_PREFIX/bin/${to_unlink};
            fi 

        done


        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/lib/*;
        do  
            to_unlink=$(basename ${f});

            if [ -L "$CONDA_PREFIX/lib/${to_unlink}" ]; then
            unlink $CONDA_PREFIX/lib/${to_unlink};
            fi 
            
        done


        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm/bin/*;
        do  
            to_unlink=$(basename ${f});

            if [ -L "$CONDA_PREFIX/bin/${to_unlink}" ]; then
            unlink $CONDA_PREFIX/bin/${to_unlink};
            fi 
            
        done

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm/lib/*;
        do  
            to_unlink=$(basename ${f});

            if [ -L "$CONDA_PREFIX/lib/${to_unlink}" ]; then
            unlink $CONDA_PREFIX/lib/${to_unlink};
            fi 
            
        done

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm/libdevice/*;
        do  
            to_unlink=$(basename ${f});

            if [ -L "$CONDA_PREFIX/lib/${to_unlink}" ]; then
            unlink $CONDA_PREFIX/lib/${to_unlink};
            fi 
            
        done

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/include/*;
        do 
            to_unlink=$(basename ${f});

            if [ -L "$CONDA_PREFIX/include/${to_unlink}" ]; then
            unlink $CONDA_PREFIX/include/${to_unlink};
            fi 
        done    
}


UNAME=$(uname)
if [[ $UNAME == "Linux" ]]; then 
   remove_symlink_linux

else
   remove_symlink_osx

fi