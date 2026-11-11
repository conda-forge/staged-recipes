#include <zip/zip.h>
#include <stdlib.h>

#define CHECK(condition)                                                        \
  do {                                                                        \
    fprintf(stderr, "Checking: %s\n", #condition);                              \
    fflush(stderr);                                                           \
    if (!(condition)) {                                                       \
      fprintf(stderr, "Failed: %s\n", #condition);                             \
      return 1;                                                              \
    }                                                                        \
  } while (0)

int main(void) {
  const char payload[] = "kuba-zip archive round trip";
  void *data = NULL;
  size_t size = 0;
  int result;
  struct zip_t *archive;
  CHECK((archive = zip_open("smoke.zip", ZIP_DEFAULT_COMPRESSION_LEVEL, 'w')) != NULL);
  CHECK(zip_entry_open(archive, "message.txt") >= 0);
  CHECK(zip_entry_write(archive, payload, sizeof(payload)) >= 0);
  CHECK(zip_entry_close(archive) >= 0);
  fprintf(stderr, "Closing written archive\n");
  fflush(stderr);
  zip_close(archive);

  CHECK((archive = zip_open("smoke.zip", 0, 'r')) != NULL);
  CHECK(zip_entries_total(archive) == 1);
  CHECK(zip_entry_open(archive, "message.txt") >= 0);
  CHECK(zip_entry_read(archive, &data, &size) >= 0);
  result = (size != sizeof(payload) || memcmp(data, payload, sizeof(payload)) != 0);
  fprintf(stderr, "Freeing entry data\n");
  fflush(stderr);
  free(data);
  CHECK(zip_entry_close(archive) >= 0);
  fprintf(stderr, "Closing read archive\n");
  fflush(stderr);
  zip_close(archive);
  CHECK(remove("smoke.zip") == 0);
  return result;
}
