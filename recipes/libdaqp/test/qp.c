#include <daqp/api.h>
#include <stdio.h>
int main(void) {
  /* min 0.5 x'x - x1 - x2 s.t. -1 <= x <= 1 and x1 + x2 <= 1 */
  c_float H[4] = {1, 0, 0, 1}, f[2] = {-1, -1};
  c_float A[2] = {1, 1}, bupper[3] = {1, 1, 1}, blower[3] = {-1, -1, -1e30};
  int sense[3] = {0, 0, 0};
  DAQPProblem qp = {2, 3, 2, H, f, A, bupper, blower, sense};
  c_float x[2], lam[3];
  DAQPResult res; res.x = x; res.lam = lam;
  daqp_quadprog(&res, &qp, NULL);
  printf("%d %g %g\n", res.exitflag, x[0], x[1]);
  return res.exitflag == 1 && x[0] > 0.49 && x[0] < 0.51 ? 0 : 1;
}
