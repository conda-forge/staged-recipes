#include <asmjit/asmjit.h>

int main() {
  asmjit::CodeHolder code;
  asmjit::Environment env = asmjit::Environment::host();
  code.init(env);
  return code.environment().arch() == env.arch() ? 0 : 1;
}
