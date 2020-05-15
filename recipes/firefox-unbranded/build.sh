#!/bin/bash

APP_DIR=$PREFIX/bin/FirefoxApp
LAUNCH_SCRIPT=$PREFIX/bin/firefox

mkdir -p $APP_DIR
mv * $APP_DIR
BIN_LOCATION=$APP_DIR/firefox
ln -s $BIN_LOCATION $LAUNCH_SCRIPT
