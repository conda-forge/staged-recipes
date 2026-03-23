#include "person.pb.h"

#include <string>

int main() {
  smoke::Person person;
  person.set_name("conda-forge");
  person.set_id(33);

  const std::string encoded = person.SerializeAsString();
  if (encoded.empty()) {
    return 1;
  }

  smoke::Person decoded;
  if (!decoded.ParseFromString(encoded)) {
    return 1;
  }

  if (decoded.name() != "conda-forge" || decoded.id() != 33) {
    return 1;
  }

  return 0;
}
