#include "double-conversion/double-conversion.h"
#include "double-conversion/bignum.h"

using namespace double_conversion;

Bignum::Bignum()
    : bigits_buffer_(), bigits_(bigits_buffer_, kBigitCapacity), used_digits_(0), exponent_(0) {
  for (int i = 0; i < kBigitCapacity; ++i) {
    bigits_[i] = 0;
  }
}

int main (void) {
    Bignum bignum;
    return 0;
}

