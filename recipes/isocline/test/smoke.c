#include <isocline.h>
#include <string.h>

int main(void) {
  const char* copy = ic_strdup("isocline");
  if (copy == NULL) return 1;
  int result = (IC_VERSION != 110 || strcmp(copy, "isocline") != 0);
  ic_free((void*)copy);
  if (!ic_char_is_digit("7", 1)) return 1;
  if (ic_char_is_digit("x", 1)) return 1;
  return result;
}
