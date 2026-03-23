#include "absl/status/statusor.h"
#include "absl/strings/cord.h"
#include "absl/strings/str_format.h"
#include "absl/time/clock.h"
#include "absl/time/time.h"

namespace {

absl::StatusOr<absl::Cord> BuildMessage() {
  return absl::Cord(
      absl::StrFormat("current_time=%d", absl::ToUnixNanos(absl::Now())));
}

}

int main() {
  auto message = BuildMessage();
  if (!message.ok() || message->empty()) {
    return 1;
  }
  return 0;
}
