#ifndef DYDX_V4_PROTO_EXPORT_H
#define DYDX_V4_PROTO_EXPORT_H

#if defined(_MSC_VER)
    #if defined(dydx_v4_proto_EXPORTS)
        #define DYDX_V4_PROTO_API __declspec(dllexport)
    #else
        #define DYDX_V4_PROTO_API __declspec(dllimport)
    #endif
#else
    #define DYDX_V4_PROTO_API
#endif

#endif // DYDX_V4_PROTO_EXPORT_H
