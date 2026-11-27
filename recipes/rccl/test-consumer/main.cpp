#include <rccl/rccl.h>
#include <cstdio>

int main()
{
    int version = 0;
    if (ncclGetVersion(&version) != ncclSuccess || version != NCCL_VERSION_CODE)
    {
        return 1;
    }
    std::printf("RCCL provides NCCL API version %d\n", version);
    return ncclGetErrorString(ncclSuccess) ? 0 : 1;
}
