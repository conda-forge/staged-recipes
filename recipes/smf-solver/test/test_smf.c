#include <math.h>
#include <stdio.h>
#include <string.h>
#include <smf/smf_c.h>

int main(void) {
    /* 4x4 symmetric indefinite KKT matrix:
     *   [ 2  0  1  0 ]   [ 1 ]   [  5 ]
     *   [ 0  3  0  1 ] * [ 2 ] = [ 10 ]
     *   [ 1  0  0  0 ]   [ 3 ]   [  1 ]
     *   [ 0  1  0  0 ]   [ 4 ]   [  2 ]
     * Lower-triangular 0-based CSC; exact inertia: (pos=2, neg=2, zero=0).
     */
    static const int col_ptr[5] = {0, 2, 4, 4, 4};
    static const int row_idx[4] = {0, 2, 1, 3};
    static const double vals[4] = {2.0, 1.0, 3.0, 1.0};
    double rhs[4] = {5.0, 10.0, 1.0, 2.0};
    const double expected[4] = {1.0, 2.0, 3.0, 4.0};

    if (smf_c_abi_version() != SMF_C_ABI_VERSION) {
        fprintf(stderr, "ABI mismatch: %d != %d\n", smf_c_abi_version(), SMF_C_ABI_VERSION);
        return 1;
    }

    smf_ipm_control_t ctrl;
    smf_ipm_default_control(&ctrl);
    ctrl.num_threads = 1;

    smf_ipm_session_t sess = NULL;
    if (smf_ipm_create(&sess) != SMF_OK) return 2;
    if (smf_ipm_analyse(sess, 4, col_ptr, row_idx, vals, &ctrl, NULL) != SMF_OK) return 3;

    smf_ipm_info_t info;
    memset(&info, 0, sizeof(info));
    info.struct_size = (int)sizeof(info);
    if (smf_ipm_factor(sess, SMF_INDEF, vals, &ctrl, &info, NULL) != SMF_OK) return 4;

    if (info.num_pos != 2 || info.num_neg != 2 || info.num_zero != 0) {
        fprintf(stderr, "Unexpected inertia: (%d, %d, %d)\n",
                info.num_pos, info.num_neg, info.num_zero);
        return 5;
    }

    if (smf_ipm_solve(sess, SMF_SOLVE_FULL, 1, rhs, 4, &ctrl, NULL) != SMF_OK) return 6;

    for (int i = 0; i < 4; ++i) {
        if (fabs(rhs[i] - expected[i]) > 1e-12) {
            fprintf(stderr, "x[%d] = %.16g, expected %.16g\n", i, rhs[i], expected[i]);
            return 7;
        }
    }

    smf_ipm_free(&sess);
    printf("smf %s (%s) consumer test OK\n", smf_version(), smf_blas_backend());
    return 0;
}
