mkdir -p $PREFIX/bin
make vcctl 
cp ./_output/bin/vcctl $PREFIX/bin/vcctl && chmod +x vcctl