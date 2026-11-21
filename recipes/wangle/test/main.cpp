#include <openssl/x509.h>
#include <wangle/ssl/SSLUtil.h>

int main() {
  X509* cert = X509_new();
  X509_NAME_add_entry_by_txt(
      X509_get_subject_name(cert),
      "CN",
      MBSTRING_ASC,
      reinterpret_cast<const unsigned char*>("wangle"),
      -1,
      -1,
      0);
  auto common_name = wangle::SSLUtil::getCommonName(cert);
  X509_free(cert);
  return common_name && *common_name == "wangle" ? 0 : 1;
}
