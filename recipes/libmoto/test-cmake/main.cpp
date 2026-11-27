#include <moto/ocp/sym.hpp>

int main() {
    const auto x = moto::sym::state("consumer_state", 1);
    return x->dim() == 1 ? 0 : 1;
}
