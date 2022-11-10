#include <openvino/frontend/manager.hpp>
#include <iostream>

int main() {
    std::cout << ov::frontend::FrontEndManager().get_available_front_ends().size();
    return 0;
}
