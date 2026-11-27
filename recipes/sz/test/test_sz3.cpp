#include <SZ3/api/sz.hpp>
#include <SZ3/version.hpp>

#include <cmath>
#include <cstdio>
#include <cstring>
#include <vector>

int main() {
    if (std::strcmp(SZ3_VER, "3.4.0") != 0) {
        std::printf("unexpected SZ3 version %s\n", SZ3_VER);
        return 1;
    }
    const size_t nx = 40, ny = 50, nz = 60;
    std::vector<float> data(nx * ny * nz);
    for (size_t i = 0; i < data.size(); ++i) {
        data[i] = static_cast<float>(std::sin(0.01 * static_cast<double>(i)));
    }
    SZ3::Config conf(nx, ny, nz);
    conf.cmprAlgo = SZ3::ALGO_INTERP_LORENZO;
    conf.errorBoundMode = SZ3::EB_ABS;
    conf.absErrorBound = 1e-3;

    size_t cmpSize = 0;
    char *cmpData = SZ_compress(conf, data.data(), cmpSize);
    std::vector<float> dec(data.size());
    float *decData = dec.data();
    SZ_decompress(conf, cmpData, cmpSize, decData);
    delete[] cmpData;

    double maxErr = 0;
    for (size_t i = 0; i < data.size(); ++i) {
        const double err = std::fabs(static_cast<double>(data[i]) - dec[i]);
        if (std::isnan(err) || err > maxErr) maxErr = err;  // a NaN stays and fails the check
    }
    std::printf("SZ3 %s: ratio %.1f, max error %g\n", SZ3_VER, data.size() * sizeof(float) / double(cmpSize), maxErr);
    return maxErr <= conf.absErrorBound ? 0 : 1;
}
