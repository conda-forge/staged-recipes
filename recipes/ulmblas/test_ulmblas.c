/*
 *  Test of the installed libulmblas: a matrix product through CBLAS and
 *  through the Fortran 77 interface, compared with a loop; prints the
 *  selected backend.
 */
#include <math.h>
#include <stdio.h>

#include <cblas.h>

const char *ulmblas_backend(void);
void dgemm_(const char *transA, const char *transB, const int *m,
            const int *n, const int *k, const double *alpha, const double *A,
            const int *ldA, const double *B, const int *ldB,
            const double *beta, double *C, const int *ldC);

#define M 37
#define N 29
#define K 41

int
main(void)
{
    static double A[M * K], B[K * N], C1[M * N], C2[M * N], R[M * N];
    for (int i = 0; i < M * K; ++i) {
	A[i] = (double)((i * 7) % 13) - 6.0;
    }
    for (int i = 0; i < K * N; ++i) {
	B[i] = (double)((i * 5) % 11) - 5.0;
    }
    for (int j = 0; j < N; ++j) {
	for (int i = 0; i < M; ++i) {
	    double s = 0;
	    for (int l = 0; l < K; ++l) {
		s += A[i + l * M] * B[l + j * K];
	    }
	    R[i + j * M] = s;
	}
    }
    cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans, M, N, K, 1.0, A,
                M, B, K, 0.0, C1, M);
    const int m = M, n = N, k = K;
    const double one = 1.0, zero = 0.0;
    dgemm_("N", "N", &m, &n, &k, &one, A, &m, B, &k, &zero, C2, &m);

    double err = 0;
    for (int i = 0; i < M * N; ++i) {
	err = fmax(err, fabs(C1[i] - R[i]));
	err = fmax(err, fabs(C2[i] - R[i]));
    }
    printf("ulmBLAS backend %s, max error %g\n", ulmblas_backend(), err);
    return err == 0 ? 0 : 1;
}
