#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <flexiblas/flexiblas_api.h>

extern void dgemm_(const char *transa, const char *transb, const int *m, const int *n, const int *k,
                   const double *alpha, const double *a, const int *lda,
                   const double *b, const int *ldb, const double *beta,
                   double *c, const int *ldc);

extern void dgesvd_(const char *jobu, const char *jobvt, const int *m, const int *n,
                    double *a, const int *lda, double *s, double *u, const int *ldu,
                    double *vt, const int *ldvt, double *work, const int *lwork,
                    int *info);

static int check_dgemm(void) {
    const int m = 2, n = 2, k = 2;
    const int lda = 2, ldb = 2, ldc = 2;
    const double alpha = 1.0, beta = 0.0;
    const char trans = 'N';

    const double a[4] = {1.0, 3.0, 2.0, 4.0};  /* column-major [[1,2],[3,4]] */
    const double b[4] = {1.0, 0.0, 0.0, 1.0};  /* identity */
    double c[4] = {0.0, 0.0, 0.0, 0.0};

    dgemm_(&trans, &trans, &m, &n, &k, &alpha, a, &lda, b, &ldb, &beta, c, &ldc);

    return fabs(c[0] - 1.0) < 1e-12 &&
           fabs(c[1] - 3.0) < 1e-12 &&
           fabs(c[2] - 2.0) < 1e-12 &&
           fabs(c[3] - 4.0) < 1e-12;
}

static int check_dgesvd(void) {
    const int m = 2, n = 2;
    const int lda = 2, ldu = 2, ldvt = 2;
    const char job = 'A';
    int info = 0;
    int lwork = -1;
    double a[4] = {1.0, 3.0, 2.0, 4.0};
    double s[2];
    double u[4];
    double vt[4];
    double work_query = 0.0;

    dgesvd_(&job, &job, &m, &n, a, &lda, s, u, &ldu, vt, &ldvt, &work_query, &lwork, &info);
    if (info != 0) {
        return 0;
    }

    lwork = (int)work_query;
    if (lwork < 8) {
        lwork = 8;
    }
    double *work = (double *)malloc((size_t)lwork * sizeof(double));
    if (!work) {
        return 0;
    }

    a[0] = 1.0; a[1] = 3.0; a[2] = 2.0; a[3] = 4.0;
    dgesvd_(&job, &job, &m, &n, a, &lda, s, u, &ldu, vt, &ldvt, work, &lwork, &info);
    free(work);

    if (info != 0) {
        return 0;
    }

    return s[0] >= s[1] && s[0] > 0.0 && s[1] > 0.0;
}

static int check_requested_backend(void) {
    const char *requested = getenv("FLEXIBLAS");
    char loaded[128];

    if (requested == NULL || requested[0] == '\0') {
        return 1;
    }
    if (flexiblas_current_backend(loaded, sizeof(loaded)) <= 0) {
        fprintf(stderr, "flexiblas_current_backend failed\n");
        return 0;
    }
    if (strcmp(loaded, requested) != 0) {
        fprintf(stderr,
                "flexiblas BLAS backend %s not loaded (got %s). Loading default is not acceptable.\n",
                requested, loaded);
        return 0;
    }
    printf("loaded backend %s\n", loaded);
    return 1;
}

int main(void) {
    if (!check_requested_backend()) {
        return 1;
    }
    if (!check_dgemm()) {
        fprintf(stderr, "DGEMM check failed\n");
        return 1;
    }
    if (!check_dgesvd()) {
        fprintf(stderr, "DGESVD check failed\n");
        return 1;
    }
    printf("C BLAS/LAPACK checks passed\n");
    return 0;
}
