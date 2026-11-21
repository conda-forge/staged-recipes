#include <fb303/ServiceData.h>

int main() {
  auto* data = facebook::fb303::ServiceData::get();
  data->setCounter("conda_forge_test", 42);
  return data->getCounter("conda_forge_test") == 42 ? 0 : 1;
}
