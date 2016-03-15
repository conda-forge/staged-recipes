if [ `uname` == Darwin ]; then
    export MACOSX_DEPLOYMENT_TARGET=10.7
fi

# This is a relocatable build of node.  
#    Standard builds with configure/make/make install are broken.
make -j$CPU_COUNT binary

for i in $(\ls -d node-v*.tar.gz)
do
    tar -zxf $i -C $PREFIX/ --strip-components=1
done

