#!/bin/bash

mkdir -p $PREFIX/etc/mq
cp $RECIPE_DIR/etc/passfile.sample $PREFIX/etc/mq/
cp $RECIPE_DIR/etc/imqbrokerd.conf $PREFIX/etc/mq/
cp $RECIPE_DIR/etc/passfile.sample $PREFIX/etc/mq/

cp $RECIPE_DIR/bin/imq $PREFIX/bin
cp $RECIPE_DIR/bin/imqcmd $PREFIX/bin

mkdir -p $PREFIX/source/MessageQueue/mq
cp -R . $PREFIX/source/MessageQueue/.
