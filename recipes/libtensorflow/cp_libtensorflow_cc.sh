# copy libraries
cp bazel-bin/tensorflow/libtensorflow_cc.so ${PREFIX}/lib/
cp bazel-bin/tensorflow/libtensorflow_framework.so ${PREFIX}/lib/

# remove cc files
find bazel-genfiles/ -name "*.cc" -type f -delete
find tensorflow/cc -name "*.cc" -type f -delete
find tensorflow/core -name "*.cc" -type f -delete
find third_party -name "*.cc" -type f -delete

# copy includes
mkdir -p ${PREFIX}/include/tensorflow
cp -r bazel-genfiles/* ${PREFIX}/include/
cp -r tensorflow/cc ${PREFIX}/include/tensorflow
cp -r tensorflow/core ${PREFIX}/include/tensorflow
cp -r third_party ${PREFIX}/include

# link eigen
for file in $(ls ${PREFIX}/include/eigen3)
do
	ln -s ${PREFIX}/include/eigen3/${file} ${PREFIX}/include/${file}
done
