#include <mdspan/mdspan.hpp>
#include <iostream>
#include <vector>

int main() {
    std::vector<int> data = {1, 2, 3, 4, 5, 6};
    Kokkos::mdspan<int, Kokkos::extents<size_t, 2, 3>> matrix(data.data());

    if (matrix(0, 0) != 1 || matrix(1, 2) != 6) {
        std::cerr << "mdspan test failed!" << std::endl;
        return 1;
    }

    std::cout << "mdspan test passed!" << std::endl;
    return 0;
}
