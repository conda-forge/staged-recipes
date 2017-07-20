python setup.py install --single-version-externally-managed --record record.txt

REM Install BeakerX kernel specs
python setup.py kernels

REM Update kernelspec_class in jupyter_notebook_config.json
python setup.py kernelspec_class

REM Copy custom CSS and assets to notebook custom directory
python setup.py custom_css
