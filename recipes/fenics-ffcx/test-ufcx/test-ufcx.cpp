#include <stdio.h>
#include "ufcx.h"

int main(int argc, char** argv) {
  printf("%d.%d.%d\n", UFCX_VERSION_MAJOR, UFCX_VERSION_MINOR, UFCX_VERSION_MAINTENANCE);
  return 0;
}
