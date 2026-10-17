// Test of the conda package: solves a lowest-order hybrid system (one unknown per cell and per face) on an n x n
// Cartesian grid of the unit square, homogeneous Dirichlet conditions, with the uncondensed interface.
// Local matrix of a cell with m faces: [m, -1...; -1, I] (the Laplacian of a star), positive semi-definite; the
// boundary faces are removed: the condensed system is symmetric positive definite.
#include <fhhos4>
#include <cmath>
#include <cstring>
#include <iostream>
#include <string>
#include <vector>

int main()
{
	const char* version = fhhos4::Version();
	std::cout << "fhhos4 " << version << ", client compiled with Eigen ";
#ifdef EIGEN_PATCH_VERSION
	std::cout << EIGEN_MAJOR_VERSION << "." << EIGEN_MINOR_VERSION << "." << EIGEN_PATCH_VERSION;
#else
	std::cout << EIGEN_WORLD_VERSION << "." << EIGEN_MAJOR_VERSION << "." << EIGEN_MINOR_VERSION;
#endif
	std::cout << ", max alignment " << EIGEN_MAX_ALIGN_BYTES << " bytes" << std::endl;
	if (std::strncmp(version, EXPECTED_VERSION, std::strlen(EXPECTED_VERSION)) != 0 || std::string(FHHOS4_VERSION) != EXPECTED_VERSION)
	{
		std::cerr << "Version " << version << " (header " << FHHOS4_VERSION << "), " << EXPECTED_VERSION << " expected" << std::endl;
		return 1;
	}

	const int n = 64;
	// Interior faces: vertical ones (between the cells (i, j) and (i+1, j)), then horizontal ones
	auto vertical = [n](int i, int j) { return j * (n - 1) + i; };              // i < n-1
	auto horizontal = [n](int i, int j) { return n * (n - 1) + j * n + i; };    // j < n-1
	const int nCells = n * n, nFaces = 2 * n * (n - 1);

	using Triplet = Eigen::Triplet<double>;
	std::vector<Triplet> tt, tf, ff;
	for (int j = 0; j < n; j++)
		for (int i = 0; i < n; i++)
		{
			int cell = j * n + i;
			std::vector<int> faces;
			if (i > 0)     faces.push_back(vertical(i - 1, j));
			if (i < n - 1) faces.push_back(vertical(i, j));
			if (j > 0)     faces.push_back(horizontal(i, j - 1));
			if (j < n - 1) faces.push_back(horizontal(i, j));
			tt.emplace_back(cell, cell, 4.0); // 4 faces, boundary ones included
			for (int f : faces)
			{
				tf.emplace_back(cell, f, -1.0);
				ff.emplace_back(f, f, 1.0);
			}
		}
	fhhos4::SparseMatrix A_TT(nCells, nCells), A_TF(nCells, nFaces), A_FF(nFaces, nFaces);
	A_TT.setFromTriplets(tt.begin(), tt.end());
	A_TF.setFromTriplets(tf.begin(), tf.end());
	A_FF.setFromTriplets(ff.begin(), ff.end());

	fhhos4::Solver solver;
	solver.Dimension = 2;
	solver.FaceDegree = 0;
	solver.CellDegree = 0;
	solver.SetupSymmetric(A_TT, A_TF, A_FF, Eigen::VectorXd::Ones(nCells), Eigen::VectorXd::Ones(nFaces));

	Eigen::VectorXd b_T = Eigen::VectorXd::Ones(nCells) / nCells, b_F = Eigen::VectorXd::Zero(nFaces);
	Eigen::VectorXd x_T(nCells), x_F = Eigen::VectorXd::Zero(nFaces);
	fhhos4::Result result = solver.Solve(b_T, b_F, x_T, x_F);
	std::cout << solver.NumberOfLevels() << " levels, " << result.Iterations << " iterations, relative residual "
	          << result.RelativeResidual << std::endl;

	// Residual of the uncondensed system
	Eigen::VectorXd r_T = b_T - A_TT * x_T - A_TF * x_F;
	Eigen::VectorXd r_F = b_F - Eigen::VectorXd(A_TF.transpose() * x_T) - A_FF * x_F;
	double residual = std::sqrt(r_T.squaredNorm() + r_F.squaredNorm()) / b_T.norm();
	std::cout << "Relative residual of the uncondensed system: " << residual << std::endl;
	return result.Converged && solver.NumberOfLevels() > 1 && residual < 1e-6 ? 0 : 1;
}
