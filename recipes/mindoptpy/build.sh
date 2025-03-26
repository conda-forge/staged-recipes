#!/bin/bash

if [ "`uname`" = "Darwin" ]; then
    if [ "`uname -m`" = "arm64" ]; then
        if [ "$CONDA_PY" = "311" ]; then
            pip install https://files.pythonhosted.org/packages/77/af/66286b1c7a9b077fceec8de8a89e0f4a3e4d44fe5737512c659c6264d7c8/mindoptpy-1.1.1-cp311-cp311-macosx_11_0_arm64.whl --no-deps
        elif [ "$CONDA_PY" = "310" ]; then
            pip install https://files.pythonhosted.org/packages/7d/d6/19a03ce332cf1ab55f8bfe773d5c0db79eb3f7a6327cbeda7897a6fc79d4/mindoptpy-1.1.1-cp310-cp310-macosx_11_0_arm64.whl --no-deps
        elif [ "$CONDA_PY" = "39" ]; then
            pip install https://files.pythonhosted.org/packages/05/64/6c8f9580ce0add6530adc12378b8eaef596639b8c4b6b6cf0bbd1eeaa75c/mindoptpy-1.1.1-cp39-cp39-macosx_11_0_arm64.whl --no-deps
        elif [ "$CONDA_PY" = "38" ]; then
            pip install https://files.pythonhosted.org/packages/bd/19/c3e40dac43c12ac571f1648c81fbccf6aab513e7bde343ca7123ed456d3f/mindoptpy-1.1.1-cp38-cp38-macosx_11_0_arm64.whl --no-deps
        fi
    else
        if [ "$CONDA_PY" = "311" ]; then
            pip install https://files.pythonhosted.org/packages/3b/46/c5aa4ce8fa8661cf4c0912c258576c2f7dc25719e2d1a48b38aa2e7ec407/mindoptpy-1.1.1-cp311-cp311-macosx_10_7_x86_64.whl --no-deps
        elif [ "$CONDA_PY" = "310" ]; then
            pip install https://files.pythonhosted.org/packages/95/28/6493eee3e44c55c2c6654764a70dd8948e3ef40833a857979900e125316a/mindoptpy-1.1.1-cp310-cp310-macosx_10_7_x86_64.whl --no-deps
        elif [ "$CONDA_PY" = "39" ]; then
            pip install https://files.pythonhosted.org/packages/49/e7/a9be47cc94446724a72b9263b6c1403c286e5facff26e429f3add8112bdc/mindoptpy-1.1.1-cp39-cp39-macosx_10_7_x86_64.whl --no-deps
        elif [ "$CONDA_PY" = "38" ]; then
            pip install https://files.pythonhosted.org/packages/81/39/67bbad0b6f886e83249eda130edf4699abf1f96067de1dc0c4720cbbf722/mindoptpy-1.1.1-cp38-cp38-macosx_10_7_x86_64.whl --no-deps
        elif [ "$CONDA_PY" = "37" ]; then
            pip install https://files.pythonhosted.org/packages/c0/59/9316191a2773148e59b6304bdcaa3a112015d5ddc1cfbdfea9ffa5c0f106/mindoptpy-1.1.1-cp37-cp37m-macosx_10_7_x86_64.whl --no-deps
        elif [ "$CONDA_PY" = "36" ]; then
            pip install https://files.pythonhosted.org/packages/5d/3d/704a65494f7eb054e457191b17768d64229b38e692d032e2744e95c49c0f/mindoptpy-1.1.1-cp36-cp36m-macosx_10_7_x86_64.whl --no-deps
        fi
    fi
elif [ "`uname`" = "Linux" ]; then
    if [ "`uname -m`" = "aarch64" ]; then
        if [ "$CONDA_PY" = "311" ]; then
            pip install https://files.pythonhosted.org/packages/b4/e9/446ee786152350395db2ae746e6f3a3ef9517b321b22dbe87b3f8359e9a8/mindoptpy-1.1.1-cp311-cp311-manylinux2014_aarch64.whl --no-deps
        elif [ "$CONDA_PY" = "310" ]; then
            pip install https://files.pythonhosted.org/packages/bb/3b/2474334ae1fca441c295dc47e1c76005aaea38fbaecceb8365b82f2a0bc5/mindoptpy-1.1.1-cp310-cp310-manylinux2014_aarch64.whl --no-deps
        elif [ "$CONDA_PY" = "39" ]; then
            pip install https://files.pythonhosted.org/packages/d1/b2/60b10bff9751d9f60eac05208a7a4658f576ccee18003a7f2327aed2c306/mindoptpy-1.1.1-cp39-cp39-manylinux2014_aarch64.whl --no-deps
        elif [ "$CONDA_PY" = "38" ]; then
            pip install https://files.pythonhosted.org/packages/48/4c/05f1c32f876aea1bed087356055397edadc306a7ca781bf5484a0b429ac3/mindoptpy-1.1.1-cp38-cp38-manylinux2014_aarch64.whl --no-deps
        elif [ "$CONDA_PY" = "37" ]; then
            pip install https://files.pythonhosted.org/packages/63/1a/94484badd598c59b9936ce691f04460cea31d3847cb106e876a7a01f92bf/mindoptpy-1.1.1-cp37-cp37m-manylinux2014_aarch64.whl --no-deps
        fi
    else
        if [ "$CONDA_PY" = "311" ]; then
            pip install https://files.pythonhosted.org/packages/66/4e/857810f72f0757897a928230634fa731e7abd356d40fbcb603849d1e5003/mindoptpy-1.1.1-cp311-cp311-manylinux2014_x86_64.whl --no-deps
        elif [ "$CONDA_PY" = "310" ]; then
            pip install https://files.pythonhosted.org/packages/7e/4f/191d70fc3474cb264687024a13e138393db14d595b7aef82e5a86636463f/mindoptpy-1.1.1-cp310-cp310-manylinux2014_x86_64.whl --no-deps
        elif [ "$CONDA_PY" = "39" ]; then
            pip install https://files.pythonhosted.org/packages/af/65/5aa5ff066c086652a029b1e2565e029cb69b97eb9f4da893160d2db04894/mindoptpy-1.1.1-cp39-cp39-manylinux2014_x86_64.whl --no-deps
        elif [ "$CONDA_PY" = "38" ]; then
            pip install https://files.pythonhosted.org/packages/7e/f3/60153b1bffdca386bc54d00f05c0b8fcdd1f0b4eacb1d0943cc09ba5a8c2/mindoptpy-1.1.1-cp38-cp38-manylinux2014_x86_64.whl --no-deps
        elif [ "$CONDA_PY" = "37" ]; then
            pip install https://files.pythonhosted.org/packages/d5/64/f31b593aacc7e7c0e736444221a71ac0c8fb2793107986baaed1cc2761b0/mindoptpy-1.1.1-cp37-cp37m-manylinux2014_x86_64.whl --no-deps
        elif [ "$CONDA_PY" = "36" ]; then
            pip install https://files.pythonhosted.org/packages/39/16/848b6a0192f4e688b95c45d58c9768baaae6dbe356673d239d28122d9b7f/mindoptpy-1.1.1-cp36-cp36m-manylinux2014_x86_64.whl --no-deps
        fi
    fi
fi
