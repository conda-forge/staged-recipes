#include <Magnum/Primitives/Cube.h>
#include <Magnum/Trade/MeshData.h>

int main() {
    Magnum::Trade::MeshData cube = Magnum::Primitives::cubeSolid();
    return cube.attributeCount() > 0 ? 0 : 1;
}
