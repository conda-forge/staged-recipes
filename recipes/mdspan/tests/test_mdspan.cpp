#include <experimental/mdspan>
#include <iostream>
#include <vector>

namespace stdex = std::experimental;

int main() {
    // Create a simple 1D array
    std::vector<int> data = {1, 2, 3, 4, 5, 6};

    // Create a 2x3 mdspan view of the data
    stdex::mdspan<int, stdex::extents<size_t, 2, 3>> matrix(data.data());

    // Access and verify elements
    if (matrix(0, 0) != 1 || matrix(0, 1) != 2 || matrix(0, 2) != 3 ||
        matrix(1, 0) != 4 || matrix(1, 1) != 5 || matrix(1, 2) != 6) {
        std::cerr << "Error: mdspan element access failed!" << std::endl;
        return 1;
    }

    // Print success message
    std::cout << "mdspan test passed successfully!" << std::endl;
    std::cout << "Matrix[0,0] = " << matrix(0, 0) << std::endl;
    std::cout << "Matrix[1,2] = " << matrix(1, 2) << std::endl;

    return 0;
}
