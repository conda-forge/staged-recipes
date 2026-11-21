// Minimal C++ consumer of the libausaxs C API. The package ships only the shared
// library (no headers), so the entry points are declared here the way any non-Python
// client would declare them.
#include <cmath>
#include <cstdio>
#include <vector>

extern "C" {
void test_integration(int* test_value);
void get_last_error_msg(char** msg, int* status);
void debye_no_ff(double* q, double* x, double* y, double* z, double* w,
                 int nq, int nc, double* return_Iq, int* return_status);
}

int main() {
    int value = 41;
    test_integration(&value);
    if (value != 42) {
        std::fprintf(stderr, "test_integration: expected 42, got %d\n", value);
        return 1;
    }

    // Two unit scatterers 10 Å apart. The Debye sum gives I(q) = 2 + 2 sin(qr)/(qr),
    // so I(q) -> 4 as q -> 0.
    std::vector<double> x{0.0, 10.0}, y{0.0, 0.0}, z{0.0, 0.0}, w{1.0, 1.0};
    std::vector<double> q{0.01, 0.05, 0.1, 0.2, 0.3};
    std::vector<double> Iq(q.size(), 0.0);
    int status = -1;
    debye_no_ff(q.data(), x.data(), y.data(), z.data(), w.data(),
                static_cast<int>(q.size()), static_cast<int>(x.size()), Iq.data(), &status);
    if (status != 0) {
        char* msg = nullptr;
        int msg_status = -1;
        get_last_error_msg(&msg, &msg_status);
        std::fprintf(stderr, "debye_no_ff failed with status %d: %s\n", status,
                     (msg_status == 0 && msg) ? msg : "(no message)");
        return 1;
    }

    for (std::size_t i = 0; i < q.size(); ++i) {
        const double qr = q[i] * 10.0;
        const double expected = 2.0 + 2.0 * std::sin(qr) / qr;
        std::printf("q = %.2f  I(q) = %.6f  expected %.6f\n", q[i], Iq[i], expected);
        if (!std::isfinite(Iq[i]) || std::fabs(Iq[i] - expected) > 0.05 * expected) {
            std::fprintf(stderr, "I(q) deviates from the Debye sum by more than 5%%\n");
            return 1;
        }
    }
    return 0;
}
