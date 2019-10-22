if [[ "${target_platform}" == "osx-64" ]]; then
  export MACOSX_DEPLOYMENT_TARGET=10.9
fi

export CXXFLAGS="${CXXFLAGS} -i sysroot ${CONDA_BUILD_SYSROOT}"

cd code
make libdnest4.a

cd ../python
python -m pip install . -vv