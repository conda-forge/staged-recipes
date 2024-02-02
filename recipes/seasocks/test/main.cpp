#include "seasocks/PrintfLogger.h"
#include "seasocks/Server.h"

#include <memory>

using namespace seasocks;

int main() {
    auto logger = std::make_shared<PrintfLogger>(Logger::Level::Info);

    Server server(logger);
    return 0;
}
