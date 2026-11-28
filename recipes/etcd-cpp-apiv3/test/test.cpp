// Link/load test only: no etcd server is available in CI, so nothing connects.
#include <etcd/Response.hpp>
#include <etcd/SyncClient.hpp>
#include <etcd/Watcher.hpp>
#include <etcd/v3/Transaction.hpp>

#include <iostream>

int main(int argc, char** argv) {
  if (argc > 1) {
    // Never run in the test; references the symbols so the linker must resolve them.
    etcd::SyncClient client(argv[1]);
    client.put("/key", "value");
    etcd::Watcher watcher(client, "/key", [](etcd::Response) {}, true);
    watcher.Cancel();
  }
  etcdv3::Transaction txn;
  std::cout << "etcd-cpp-apiv3 OK" << std::endl;
  return 0;
}
