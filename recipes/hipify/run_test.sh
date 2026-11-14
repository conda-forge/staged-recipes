#!/bin/bash
set -euxo pipefail

# Exercise translation without requiring CUDA headers or a GPU.
printf 'cudaDeviceSynchronize();\n' > perl-input.cu
hipify-perl perl-input.cu > perl-output.hip
grep -q 'hipDeviceSynchronize' perl-output.hip

# This also checks discovery of the packaged Clang resource headers.
printf 'int main() { return 0; }\n' > clang-input.cu
hipify-clang clang-input.cu -o clang-output.hip -- -nocudainc -nocudalib
grep -q 'int main()' clang-output.hip
