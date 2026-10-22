#include <quic/codec/Types.h>

int main() {
  return quic::toString(quic::QuicVersion::QUIC_V1) == "QUIC_V1" ? 0 : 1;
}
