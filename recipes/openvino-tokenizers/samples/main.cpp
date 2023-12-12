#include <openvino/openvino.hpp>

int main() {
    ov::Core core;
#ifdef __APPLE__
    core.add_extension("libuser_ov_extensions.dylib");
#elif _WIN32
    core.add_extension("user_ov_extensions.dll");
#else
    core.add_extension("libuser_ov_extensions.so");
#endif
    return 0;
}
