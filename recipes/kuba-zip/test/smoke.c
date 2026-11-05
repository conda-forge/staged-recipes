#include <zip/zip.h>
#include <stdlib.h>

int main(void) {
  const char payload[] = "kuba-zip archive round trip";
  void *data = NULL;
  size_t size = 0;
  int result;
  struct zip_t *archive = zip_open("smoke.zip", ZIP_DEFAULT_COMPRESSION_LEVEL, 'w');
  if (archive == NULL) return 1;
  if (zip_entry_open(archive, "message.txt") < 0) return 1;
  if (zip_entry_write(archive, payload, sizeof(payload)) < 0) return 1;
  if (zip_entry_close(archive) < 0) return 1;
  zip_close(archive);

  archive = zip_open("smoke.zip", 0, 'r');
  if (archive == NULL) return 1;
  if (zip_entries_total(archive) != 1) return 1;
  if (zip_entry_open(archive, "message.txt") < 0) return 1;
  if (zip_entry_read(archive, &data, &size) < 0) return 1;
  result = (size != sizeof(payload) || memcmp(data, payload, sizeof(payload)) != 0);
  free(data);
  if (zip_entry_close(archive) < 0) return 1;
  zip_close(archive);
  if (remove("smoke.zip") != 0) return 1;
  return result;
}
