#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

int main() {
    std::vector<std::string> words{"Hello", "from", "Fil-C++!"};
    try {
        throw std::runtime_error("exceptions work");
    } catch (const std::exception &e) {
        words.emplace_back(e.what());
    }
    for (const auto &w : words) {
        std::cout << w << ' ';
    }
    std::cout << std::endl;
    return 0;
}
