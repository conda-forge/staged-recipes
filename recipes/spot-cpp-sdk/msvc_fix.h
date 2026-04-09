#pragma once

/**
 * Windows.h defines several macros that collide with member names 
 * in the Boston Dynamics Spot SDK Protobuf definitions.
 */

// NOMINMAX prevents Windows.h from defining min() and max() macros
#ifndef NOMINMAX
#  define NOMINMAX
#endif

// WIN32_LEAN_AND_MEAN excludes rarely-used services from Windows headers
#ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
#endif

#include <windows.h>

/**
 * UNDEFINE CONFLICTING MACROS
 * The following tokens are used as field names in choreography_sequence.pb.h
 * but are defined as global macros in windef.h or rpcndr.h.
 */

// Fixes error C2789: 'bosdyn::api::spot::ChoreographyStatusResponse::DWORD'
// Undefining the macro allows the compiler to treat 'DWORD' as a type-safe identifier.
#ifdef DWORD
#  undef DWORD
#endif

// Fixes error C2143: syntax error: missing ')' before 'constant'
// 'constant' is often defined in RPC headers; undefining it prevents
// syntax errors in Protobuf-generated getters/setters.
#ifdef constant
#  undef constant
#endif
