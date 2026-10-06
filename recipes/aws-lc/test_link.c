#include <openssl/crypto.h>
#include <openssl/digest.h>
#include <openssl/rand.h>
#include <openssl/service_indicator.h>
#include <openssl/ssl.h>

#include <stdio.h>
#include <string.h>

int main(void) {
  printf("awslc_version_string: %s\n", awslc_version_string());

  unsigned char buf[32];
  if (RAND_bytes(buf, sizeof(buf)) != 1) {
    fprintf(stderr, "RAND_bytes failed\n");
    return 1;
  }

  unsigned char digest[EVP_MAX_MD_SIZE];
  unsigned int digest_len = 0;
  if (EVP_Digest(buf, sizeof(buf), digest, &digest_len, EVP_sha256(), NULL) !=
      1) {
    fprintf(stderr, "EVP_Digest failed\n");
    return 1;
  }
  if (digest_len != 32) {
    fprintf(stderr, "unexpected SHA-256 length %u\n", digest_len);
    return 1;
  }

  /* Exercise libssl too, so we know it linked. */
  SSL_CTX *ctx = SSL_CTX_new(TLS_method());
  if (ctx == NULL) {
    fprintf(stderr, "SSL_CTX_new failed\n");
    return 1;
  }
  SSL_CTX_free(ctx);

  printf("ok\n");
  return 0;
}
