#pragma once

/**
 * MSVC FIXUP HEADER
 * This header resolves conflicts between Windows SDK macros and Spot SDK identifiers.
 */

// 1. Include STL chrono first. 
// This prevents 'identifier not found' errors like C3861 (_Query_perf_frequency)
// by ensuring the STL is parsed before any Windows macro interference.
#include <chrono>

// 2. Include windows.h to capture system macros
#ifndef NOMINMAX
#  define NOMINMAX
#endif
#include <windows.h>

/**
 * 3. Undefine problematic macros.
 * These tokens are defined as global macros in Windows headers but are used
 * as field names in the Spot SDK Protobuf definitions.
 */

// Fixes error C2789 related to ChoreographyStatusResponse::DWORD
#ifdef DWORD
#  undef DWORD
#endif

// Fixes error C2143 related to syntax errors near 'constant'
#ifdef constant
#  undef constant
#endif
