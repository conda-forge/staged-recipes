
# Create a minimal file, including uammd.cuh
cat > test.cu <<EOF
#include<uammd.cuh>

int main(){
  return 0;
}
EOF

# Compile the file
nvcc -std=c++14 -I$CONDA_PREFIX/include/uammd -I$CONDA_PREFIX/include/uammd/third_party test.cu -o test
