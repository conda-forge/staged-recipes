#include <fizz/crypto/Utils.h>
#include <folly/Range.h>

int main() {
  folly::StringPiece fizz{"fizz"};
  folly::StringPiece buzz{"buzz"};
  bool same = fizz::CryptoUtils::equal(folly::ByteRange(fizz), folly::ByteRange(fizz));
  bool different = fizz::CryptoUtils::equal(folly::ByteRange(fizz), folly::ByteRange(buzz));
  return same && !different ? 0 : 1;
}
