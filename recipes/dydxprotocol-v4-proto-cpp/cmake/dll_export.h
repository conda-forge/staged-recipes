#ifdef _WIN32
  #ifdef BUILDING_DLL
    #define DLL_EXPORT_API __declspec(dllexport)
  #else
    #define DLL_EXPORT_API __declspec(dllimport)
  #endif
#else
  #define DLL_EXPORT_API
#endif
