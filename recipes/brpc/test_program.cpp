// Smoke test: link against libbrpc and exercise a few basic APIs without
// touching the network.
#include <brpc/server.h>
#include <butil/logging.h>
#include <bvar/bvar.h>

int main() {
    brpc::Server server;
    bvar::Adder<int> counter("smoke_test_counter");
    counter << 42;
    LOG(INFO) << "brpc smoke test, counter=" << counter.get_value();
    return counter.get_value() == 42 ? 0 : 1;
}
