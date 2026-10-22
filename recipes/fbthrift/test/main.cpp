#include <string>

#include <thrift/lib/cpp2/protocol/Serializer.h>

#include "gen-cpp2/point_types.h"

int main() {
  example::Point point;
  point.x() = 3;
  point.y() = -7;
  point.label() = "fbthrift";

  auto bytes = apache::thrift::CompactSerializer::serialize<std::string>(point);
  auto decoded =
      apache::thrift::CompactSerializer::deserialize<example::Point>(bytes);
  return decoded == point ? 0 : 1;
}
