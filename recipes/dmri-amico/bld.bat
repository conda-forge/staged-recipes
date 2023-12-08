echo [openblas] >> site.cfg
echo library = blas >> site.cfg
echo library_dir = "%PREFIX%"\lib >> site.cfg
echo include_dir = "%PREFIX%"\include >> site.cfg

"%PYTHON%" -m pip install --no-deps --ignore-installed .
