if [[ "${target_platform}" == "osx-64" ]]; then
  export MACOSX_DEPLOYMENT_TARGET=10.9
fi

cd code
make

cd ../python
python -m pip install . -vv