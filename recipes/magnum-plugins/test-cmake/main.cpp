#include <Corrade/PluginManager/Manager.h>
#include <Magnum/Trade/AbstractImporter.h>

int main() {
    Corrade::PluginManager::Manager<Magnum::Trade::AbstractImporter> manager;
    auto importer = manager.loadAndInstantiate("StbImageImporter");
    return importer ? 0 : 1;
}
