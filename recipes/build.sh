python setup.py install --single-version-externally-managed --record record.txt

# Install BeakerX kernel specs
python setup.py kernels

# Update kernelspec_class in jupyter_notebook_config.json
python setup.py kernelspec_class

# Copy custom CSS and assets to notebook custom directory
# cp -r beakerx/custom "${PREFIX}/lib/python3.5/site-packages/notebook/static/custom" > /dev/null 2>&1
python setup.py custom_css
