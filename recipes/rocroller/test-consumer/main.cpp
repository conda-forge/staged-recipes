#include <rocRoller/Context.hpp>
#include <rocRoller/Serialization/msgpack/Msgpack.hpp>
#include <rocRoller/Utilities/Version.hpp>
#include <iostream>

int main() {
    std::cout << rocRoller::Version::Git() << '\n';
}
