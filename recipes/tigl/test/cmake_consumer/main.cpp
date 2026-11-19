#include <tigl.h>

#include <cstdio>
#include <cstring>

int main()
{
    const char* version = tiglGetVersion();
    std::printf("TiGL version: %s\n", version);
    return (version != nullptr && std::strlen(version) > 0) ? 0 : 1;
}
