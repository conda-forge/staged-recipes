#!/bin/bash

export DATA_DIR="$SP_DIR/matplotlib/mpl-data/sample_data"

mkdir -p $DATA_DIR

cp -r $SRC_DIR/lib/matplotlib/mpl-data/sample_data/* $DATA_DIR
