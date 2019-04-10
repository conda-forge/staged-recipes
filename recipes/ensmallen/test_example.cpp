#include <ensmallen.hpp>

class SquaredFunction
{
 public:
  // This returns f(x) = 2 |x|^2.
  double Evaluate(const arma::mat& x)
  {
    return 2 * std::pow(arma::norm(x), 2.0);
  }
};

int main()
{
  // The minimum is at x = [0 0 0].  Our initial point is chosen to be 
  // [1.0, -1.0, 1.0].
  arma::mat x("1.0 -1.0 1.0");

  // Create simulated annealing optimizer with default options.
  // The ens::SA<> type can be replaced with any suitable ensmallen optimizer
  // that is able to handle arbitrary functions.
  ens::SA<> optimizer;
  SquaredFunction f; // Create function to be optimized.
  optimizer.Optimize(f, x);

  std::cout << "Minimum of squared function found with simulated annealing is "
      << x;
}

