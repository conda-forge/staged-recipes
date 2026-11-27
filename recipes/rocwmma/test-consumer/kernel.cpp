#include <rocwmma/rocwmma.hpp>

// Compile device code through the installed CMake target without running it.
__global__ void fill_accumulator(float* output)
{
    rocwmma::fragment<rocwmma::accumulator, 16, 16, 16, float> fragment;
    rocwmma::fill_fragment(fragment, 1.0f);
    rocwmma::store_matrix_sync(output, fragment, 16, rocwmma::mem_row_major);
}
