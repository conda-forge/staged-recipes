#pragma once

enum {
  NDA__UNSPEC,
  NDA__DST,
  NDA__LLADDR,
  NDA__CACHEINFO,
  NDA__PROBES,
  NDA_VLAN,
  NDA_PORT,
  NDA_VNI,
  NDA_IFINDEX,
  NDA_MASTER,
  NDA_LINK_NETNSID,
  NDA_SRC_VNI,
  __NDA__MAX
};

#ifdef NDA_MAX
#undef NDA_MAX
#endif
#define NDA_MAX (__NDA__MAX - 1)
