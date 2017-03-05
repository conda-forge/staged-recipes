#include <Halide.h>
using namespace Halide;
using namespace Halide::Internal;

int main(int argc, const char **argv) {
    IRPrinter::test();
    CodeGen_C::test();
    ir_equality_test();
    bounds_test();
    expr_match_test();
    deinterleave_vector_test();
    modulus_remainder_test();
    cse_test();
    simplify_test();
    solve_test();
    target_test();
    cplusplus_mangle_test();
    is_monotonic_test();
    split_predicate_test();
    interval_test();
    associativity_test();
    generator_test();

    return 0;
}