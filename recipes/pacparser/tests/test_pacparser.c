#include <stdio.h>
#include <string.h>

#include <pacparser.h>

static const char *kPacScript =
    "function FindProxyForURL(url, host) {\n"
    "  if (host == 'www.example.com')\n"
    "    return 'PROXY proxy.example.com:8080';\n"
    "  return 'DIRECT';\n"
    "}\n";

int main(void) {
  if (!pacparser_init()) {
    fprintf(stderr, "pacparser_init() failed\n");
    return 1;
  }
  if (!pacparser_parse_pac_string(kPacScript)) {
    fprintf(stderr, "pacparser_parse_pac_string() failed\n");
    return 1;
  }

  char *proxy =
      pacparser_find_proxy("http://www.example.com/", "www.example.com");
  if (proxy == NULL || strcmp(proxy, "PROXY proxy.example.com:8080") != 0) {
    fprintf(stderr, "unexpected result: %s\n", proxy ? proxy : "(null)");
    return 1;
  }
  printf("pacparser OK: %s\n", proxy);

  pacparser_cleanup();
  return 0;
}
