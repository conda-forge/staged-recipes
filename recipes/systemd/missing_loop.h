#pragma once

/*
 * Loop flags
 */
enum {
  LO__FLAGS_READ_ONLY  = 1,
  LO__FLAGS_AUTOCLEAR  = 4,
  LO_FLAGS_PARTSCAN = 8,
  LO_FLAGS_DIRECT_IO  = 16,
};

#ifndef LOOP_CTL_GET_FREE
#define LOOP_CTL_GET_FREE 0x4C82
#endif

#ifndef LOOP_CTL_REMOVE
#define LOOP_CTL_REMOVE   0x4C81
#endif
