#!/bin/bash

for name in Assistant Designer Linguist pixeltool qml
do
    # remove old .app if it exists
    rm -rf $PREFIX/bin/${name}.app
    # rename (breaking link)
    cp -r $PREFIX/bin/${name}app $PREFIX/bin/${name}.app
    rm -r $PREFIX/bin/${name}app
done
