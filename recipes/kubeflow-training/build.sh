# do not include test folders in package or it will
# cause a conda clobber warning
rm -rf test*
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
