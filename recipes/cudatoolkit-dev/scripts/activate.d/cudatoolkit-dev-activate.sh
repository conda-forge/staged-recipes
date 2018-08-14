#!/usr/bin/env bash

create_symlink_linux() { 

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/bin/*;
        do 
            link=$(basename "$f");
            ln -sf $f $CONDA_PREFIX/bin/${link};
        done


        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/lib64/*;
        do 
            link=$(basename "$f");
            ln -sf $f $CONDA_PREFIX/lib/${link};

        done

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm/bin/*;
        do 
            link=$(basename "$f");
            ln -sf $f $CONDA_PREFIX/bin/${link};

        done

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm/lib64/*;
        do 
            link=$(basename "$f");
            ln -sf $f $CONDA_PREFIX/lib/${link};

        done

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm/libdevice/*;
        do 
            link=$(basename "$f");
            ln -sf $f $CONDA_PREFIX/lib/${link};

        done

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/include/*;
        do 
            link=$(basename "$f");
            ln -sf $f $CONDA_PREFIX/include/${link};

        done


        ln -sf $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm $CONDA_PREFIX/
        ln -sf $CONDA_PREFIX/lib $CONDA_PREFIX/lib64

}


create_symlink_osx() { 

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/bin/*;
        do 
            link=$(basename "$f");
            ln -sf $f $CONDA_PREFIX/bin/${link};
        done


        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/lib/*;
        do 
            link=$(basename "$f");
            ln -sf $f $CONDA_PREFIX/lib/${link};

        done

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm/bin/*;
        do 
            link=$(basename "$f");
            ln -sf $f $CONDA_PREFIX/bin/${link};

        done

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm/lib/*;
        do 
            link=$(basename "$f");
            ln -sf $f $CONDA_PREFIX/lib/${link};

        done

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm/libdevice/*;
        do 
            link=$(basename "$f");
            ln -sf $f $CONDA_PREFIX/lib/${link};

        done

        for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/include/*;
        do 
            link=$(basename "$f");
            ln -sf $f $CONDA_PREFIX/include/${link};

        done


        ln -sf $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm $CONDA_PREFIX/


}


UNAME=$(uname)
if [[ $UNAME == "Linux" ]]; then 
   create_symlink_linux

else
    create_symlink_osx

fi