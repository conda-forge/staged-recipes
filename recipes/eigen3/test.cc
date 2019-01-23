#include <eigen3/Eigen/Dense>
#include <cassert>

using Eigen::MatrixXf;

int
main(void)
{
  MatrixXf m(1, 1);
  m(0, 0) = 1.0;
  assert(m(0, 0) == 1.0);
  return 0;
}
