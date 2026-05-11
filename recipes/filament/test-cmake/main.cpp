#include <filament/Engine.h>

int main() {
    static_assert(sizeof(filament::Engine*) == sizeof(void*));
    auto backend = filament::Engine::Backend::DEFAULT;
    (void) backend;
    return 0;
}
