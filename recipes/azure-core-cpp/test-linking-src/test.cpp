// copy-pasted example from README
// https://github.com/Azure/azure-sdk-for-cpp/blob/96c34cb5f401e4a379c37e9d05e79980e6e0d50a/sdk/core/azure-core/README.md
#include <azure/core/diagnostics/logger.hpp>

int main()
{
    using namespace Azure::Core::Diagnostics;

    // See above for the level descriptions.
    Logger::SetLevel(Logger::Level::Verbose);

    // SetListener accepts std::function<>, which can be either lambda or a function pointer.
    Logger::SetListener([&](auto lvl, auto msg){ /* handle Logger::Level lvl and std::string msg */ });
}
