#include <iostream>
#include <string>

#include <occa.hpp>

static const char *source = R"(
@kernel void addVectors(const int N,
                        const float *a,
                        const float *b,
                        float *ab) {
  for (int i = 0; i < N; ++i; @tile(4, @outer, @inner)) {
    ab[i] = a[i] + b[i];
  }
}
)";

int main(int argc, char **argv) {
  const std::string mode = (argc > 1) ? argv[1] : "Serial";
  const int N = 12;
  float a[N], b[N], ab[N];
  for (int i = 0; i < N; ++i) {
    a[i] = i;
    b[i] = 1 - i;
    ab[i] = 0;
  }

  occa::json props;
  props["mode"] = mode;
  if (mode == "OpenCL") {
    props["platform_id"] = 0;
  }
  if (mode == "OpenCL" || mode == "CUDA") {
    props["device_id"] = 0;
  }
  occa::device device(props);
  occa::memory o_a = device.malloc<float>(N);
  occa::memory o_b = device.malloc<float>(N);
  occa::memory o_ab = device.malloc<float>(N);

  occa::kernel addVectors = device.buildKernelFromString(source, "addVectors");

  o_a.copyFrom(a);
  o_b.copyFrom(b);
  addVectors(N, o_a, o_b, o_ab);
  o_ab.copyTo(ab);

  for (int i = 0; i < N; ++i) {
    if (ab[i] != a[i] + b[i]) {
      std::cerr << mode << ": mismatch at " << i << ": " << ab[i] << '\n';
      return 1;
    }
  }
  std::cout << mode << ": OK\n";
  return 0;
}
