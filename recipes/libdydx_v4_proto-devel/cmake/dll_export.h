#if defined(_WIN32) || defined(WIN32)
  #define PROTOBUF_USE_DLLS
  #ifdef BUILDING_DLL
    #define DLL_EXPORT_API __declspec(dllexport)
  #else
    #define DLL_EXPORT_API __declspec(dllimport)
  #endif
#else
  #define DLL_EXPORT_API
#endif
