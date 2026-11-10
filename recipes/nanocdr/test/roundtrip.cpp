// Encode a few values and decode them back.
#include <cstdint>
#include <string>
#include <vector>

#include "nanocdr/nanocdr.hpp"

int main() {
  std::vector<uint8_t> storage;
  nanocdr::Encoder encoder(nanocdr::CdrHeader{}, storage);
  const int32_t number = -42;
  const double value = 3.25;
  const std::string text = "plotjuggler";
  const std::vector<int32_t> list = {1, 2, 3};
  encoder.encode(number);
  encoder.encode(value);
  encoder.encode(text);
  encoder.encode(list);

  nanocdr::Decoder decoder(encoder.encodedBuffer());
  int32_t number_out = 0;
  double value_out = 0;
  std::string text_out;
  std::vector<int32_t> list_out;
  decoder.decode(number_out);
  decoder.decode(value_out);
  decoder.decode(text_out);
  decoder.decode(list_out);
  return (number_out == number && value_out == value && text_out == text && list_out == list) ? 0 : 1;
}
