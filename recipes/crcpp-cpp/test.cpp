#include <CRC.h>

int main()
{
    const char value[] = "conda-forge";
    (void)CRC::Calculate(value, sizeof(value) - 1, CRC::CRC_32());
    return 0;
}
