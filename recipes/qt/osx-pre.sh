#!/bin/bash

for name in Assistant Designer Linguist pixeltool qml
do
    rm -r $PREFIX/bin/${name}.app
done
