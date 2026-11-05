#!/bin/bash
set -euxo pipefail

cat > aqlprofile-smoke.cpp <<'CPP'
#include <aqlprofile-sdk/aql_profile_v2.h>
#include <aqlprofile-sdk/version.h>
int main() {
    aqlprofile_version_t version{};
    return aqlprofile_get_version(&version) != HSA_STATUS_SUCCESS;
}
CPP
"${CXX}" ${CXXFLAGS:-} aqlprofile-smoke.cpp -I"${PREFIX}/include" \
    -L"${PREFIX}/lib" -lhsa-amd-aqlprofile64 ${LDFLAGS:-} -o aqlprofile-smoke
./aqlprofile-smoke
