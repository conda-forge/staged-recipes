#include <otf2/otf2.h>

int main(void)
{
    OTF2_IdMap* map = OTF2_IdMap_Create(OTF2_ID_MAP_DENSE, 1);
    uint64_t global_id = 0;
    if (!map)
    {
        return 1;
    }

    OTF2_ErrorCode status = OTF2_IdMap_AddIdPair(map, 0, 42);
    if (status == OTF2_SUCCESS)
    {
        status = OTF2_IdMap_GetGlobalId(map, 0, &global_id);
    }
    OTF2_IdMap_Free(map);
    return status == OTF2_SUCCESS && global_id == 42 ? 0 : 1;
}
