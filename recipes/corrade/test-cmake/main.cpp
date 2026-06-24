#include <Corrade/Containers/String.h>
#include <Corrade/Utility/Debug.h>

int main() {
    Corrade::Containers::String value{"corrade"};
    Corrade::Utility::Debug{} << value;
    return value.size() == 7 ? 0 : 1;
}
