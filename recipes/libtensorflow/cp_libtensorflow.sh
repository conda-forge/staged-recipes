# copy libraries
cp bazel-bin/tensorflow/libtensorflow.so ${PREFIX}/lib/
cp bazel-bin/tensorflow/libtensorflow_framework.so ${PREFIX}/lib/

# copy includes
mkdir -p ${PREFIX}/include/tensorflow
mkdir -p ${PREFIX}/include/tensorflow/c
mkdir -p ${PREFIX}/include/tensorflow/c/eager
cp tensorflow/c/c_api.h ${PREFIX}/include/tensorflow/c/
cp tensorflow/c/c_api_experimental.h ${PREFIX}/include/tensorflow/c/
cp tensorflow/c/eager/c_api.h ${PREFIX}/include/tensorflow/c/eager/
