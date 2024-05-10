#include <iostream>

#include <metatensor/torch.hpp>

int main() {
    std::cout << "found metatensor-torch v" << metatensor_torch::version() << std::endl;

    return 0;
}
