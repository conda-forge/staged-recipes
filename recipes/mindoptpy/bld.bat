@echo off

if "%CONDA_PY%" == "311" (
    pip install https://files.pythonhosted.org/packages/83/3c/46aa769dc747580676c41536de7900067e31b3ef803dbb26d7c83b98ce0c/mindoptpy-1.1.1-cp311-cp311-win_amd64.whl --no-deps
) else if "%CONDA_PY%" == "310" (
    pip install https://files.pythonhosted.org/packages/06/65/12980d3efc623a2a43f641a42416af40fab29d17c3a0b3e1915c51c0d20a/mindoptpy-1.1.1-cp310-cp310-win_amd64.whl --no-deps
) else if "%CONDA_PY%" == "39" (
    pip install https://files.pythonhosted.org/packages/07/6e/5316bd37a194ad460a7901c6d72e69317c79ee3ae4757cbbc05f7070368f/mindoptpy-1.1.1-cp39-cp39-win_amd64.whl --no-deps
) else if "%CONDA_PY%" == "38" (
    pip install https://files.pythonhosted.org/packages/a1/d8/757d75f0121e1d50d2a5efba04a62d33aa2c163c0c1c20304d698594a412/mindoptpy-1.1.1-cp38-cp38-win_amd64.whl --no-deps
) else if "%CONDA_PY%" == "37" (
    pip install https://files.pythonhosted.org/packages/33/4a/153d8d81209a7116c6170aeca149c408a408b9264bdd7f1d32ddfbfb9561/mindoptpy-1.1.1-cp37-cp37m-win_amd64.whl --no-deps
) else if "%CONDA_PY%" == "36" (
    pip install https://files.pythonhosted.org/packages/d6/31/704cd157d9c9edd1f5ac76a67d702a87adfc7f6808048cb0be221d7f02b7/mindoptpy-1.1.1-cp36-cp36m-win_amd64.whl --no-deps
)
