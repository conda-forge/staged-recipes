#!/bin/sh

cd $SRC_DIR/python
bash make_sdist.sh
cd dist
export MUJOCO_PATH=$PREFIX
python -m pip install --no-deps mujoco-*.tar.gz
