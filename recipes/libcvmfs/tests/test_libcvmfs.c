#include <stdio.h>
#include <string.h>

#include <libcvmfs.h>

int main(void) {
  cvmfs_option_map *opts = cvmfs_options_init();
  if (opts == NULL) {
    fprintf(stderr, "cvmfs_options_init() failed\n");
    return 1;
  }

  cvmfs_options_set(opts, "CVMFS_CACHE_BASE", "/tmp/test-cvmfs-cache");
  char *value = cvmfs_options_get(opts, "CVMFS_CACHE_BASE");
  if (value == NULL || strcmp(value, "/tmp/test-cvmfs-cache") != 0) {
    fprintf(stderr, "unexpected value for CVMFS_CACHE_BASE\n");
    return 1;
  }
  cvmfs_options_free(value);
  cvmfs_options_fini(opts);

  printf("libcvmfs %d.%d OK\n", LIBCVMFS_VERSION_MAJOR, LIBCVMFS_VERSION_MINOR);
  return 0;
}
