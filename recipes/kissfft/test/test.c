#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include <kiss_fftr.h>

#define N 64

int main(void)
{
    kiss_fft_scalar in[N];
    kiss_fft_cpx out[N / 2 + 1];
    int i;
    const double pi = 3.14159265358979323846;

    /* Cosine at bin 4: all energy should end up in out[4]. */
    for (i = 0; i < N; ++i)
        in[i] = (kiss_fft_scalar)cos(2.0 * pi * 4.0 * i / N);

    kiss_fftr_cfg cfg = kiss_fftr_alloc(N, 0, NULL, NULL);
    if (!cfg)
        return 1;
    kiss_fftr(cfg, in, out);
    kiss_fftr_free(cfg);

    printf("sizeof(kiss_fft_scalar) = %d, |X[4]| = %f\n",
           (int)sizeof(kiss_fft_scalar), (double)out[4].r);
    if (fabs((double)out[4].r - N / 2.0) > 1e-3)
        return 1;
    for (i = 0; i <= N / 2; ++i)
        if (i != 4 && fabs((double)out[i].r) + fabs((double)out[i].i) > 1e-3)
            return 1;
    return 0;
}
