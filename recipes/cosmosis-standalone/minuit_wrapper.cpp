#include "Minuit2/FCNBase.h"
#include "Minuit2/FunctionMinimum.h"
#include "Minuit2/MnPrint.h"
#include "Minuit2/MnMigrad.h"
#include "Minuit2/MnSimplex.h"
#include "Minuit2/MnMinimize.h"
#include "Minuit2/MnHesse.h"
// #include "Minuit2/MnScan.h"
#include <vector>
#include <iostream>

using namespace ROOT;
using namespace Minuit2;

#define MIGRAD_ALGORITHM 0
#define FALLBACK_ALGORITHM 1
#define SIMPLEX_ALGORITHM 2
// #define SCAN_ALGORITHM 3

typedef struct minuit_options{
	int max_evals;
	int strategy;
	int algorithm;
	char * save_cov;
	double tolerance;
	double width_estimate;
	int do_master_output;
} minuit_options;

typedef double (*likelihood_function)(double * params);

class CosmosisMinuitFunction : public FCNBase {
public:
	CosmosisMinuitFunction(likelihood_function f);
	virtual double Up() const;
	virtual double operator()(const std::vector<double>&) const;
private:
	likelihood_function cFunctionPointer;

};


void save_covmat(char * filename, MnUserCovariance &cov, int nparam){

	FILE * f = fopen(filename, "w");
	if (!f) {
		std::cerr << "ERROR saving covariance matrix - could not open file: " << filename << std::endl;
		return;
	}
	for (int i=0; i<nparam; i++){
		for (int j=0; j<nparam; j++){
			fprintf(f, "% le   ",cov(i,j));
		}
		fprintf(f, "\n");
	}
	fclose(f);

}

CosmosisMinuitFunction::CosmosisMinuitFunction(likelihood_function f){
	cFunctionPointer = f;
}



double CosmosisMinuitFunction::Up() const {
	// This function sets the scale of the function
	// i.e. what change in the function value corresponds
	// to a 1 sigma shift.
	// Since we are doing a log-like we want 0.5
	return 0.5;
}

double CosmosisMinuitFunction::operator()(const std::vector<double>& x) const
{
	int n = x.size();
	double p[n];
	for (int i=0; i<n; i++) p[i] = x[i];
	double v = cFunctionPointer(p);
	return v;
}

extern "C" {
int cosmosis_minuit2_wrapper(
	int nparam,
	double * start,
	double * lower,
	double * upper,
	likelihood_function f,
	const char ** param_names,
	double * cov_output,
	int * made_cov,
	minuit_options options
	)
{

	// This just wraps the cosmosis likelihood function
	CosmosisMinuitFunction func(f);

	// Set up all the parameters required, with limits.
	// Minuit warns that we should avoid parameter limits
	// if possible, but I think here that is difficult
	MnUserParameters upar;
	for (int i=0; i<nparam; i++){
		// Parameter width estimate - one tenth of the width.
		double width = options.width_estimate*(upper[i]-lower[i]);
		// Add the parameter, it's starting point, scale, min, and max.
		upar.Add(param_names[i], start[i], width, lower[i], upper[i]);
	}

	if (options.do_master_output){
		std::cout <<  std::endl <<  std::endl;
	}

	// Describe to the user what our strategy is - just output here, no logic.
	switch (options.strategy)
	{
		case 0:
			if (options.do_master_output) std::cout << "Using fast but lower quality minimization strategy." << std::endl;
			break;
		case 1:
			if (options.do_master_output) std::cout << "Using intermediate (in quality/speed) minimization strategy." << std::endl;
			break;
		case 2:
			if (options.do_master_output) std::cout << "Using high quality but slow minimization strategy." << std::endl;
			break;
		default:
			fprintf(stderr, "Internal error running the minimizer - wrong strategy %d (this should not be possible).\n", options.strategy);
			fprintf(stderr, "Try running 'make' again but if that doesn't fix it please open an issue with cosmosis to report this.\n");
			exit(1);

	}


	// Decide which minimizer to use, and tell the user
	MnApplication * minimizer;
	switch (options.algorithm)
	{
		case MIGRAD_ALGORITHM:
			minimizer = new MnMigrad(func, upar, options.strategy);
			if (options.do_master_output) std::cout << "Using MIGRAD algorithm"
				<< std::endl;
			break;
		case SIMPLEX_ALGORITHM:
			minimizer = new MnSimplex(func, upar, options.strategy);
			if (options.do_master_output) std::cout << "Using SIMPLEX algorithm"
				<< std::endl;
			break;
		case FALLBACK_ALGORITHM:
			minimizer = new MnMinimize(func, upar, options.strategy);
			if (options.do_master_output) std::cout << "Using MIGRAD algorithm but falling back to simplex on failure" << std::endl;
			break;
		// case SCAN_ALGORITHM:
		// 	minimizer = new MnScan(func, upar, options.strategy);
		// 	std::cout << "Using SCAN algorithm" << std::endl;
		// 	break;
		default:
			fprintf(stderr, "Internal error running the minimizer - wrong algorithm %d (this should not be possible).\n", options.algorithm);
			fprintf(stderr, "Please open an issue with cosmosis to report this.\n");
			exit(1);
	}

	if (options.do_master_output){
		std::cout <<  std::endl;
		std::cout <<  std::endl;
	}
	// Run the minimization
	std::cout << "Tolerance = " << options.tolerance << std::endl;
	std::cout << "Evaluations remaining = " << options.max_evals << std::endl;
	FunctionMinimum min = (*minimizer)(options.max_evals, options.tolerance);

	// Print out the convergence information
	if (options.do_master_output) std::cout << std::endl <<
		"MINUIT convergence information:" << min;

	// Return the results back to the calling function
	// by overwriting the start vector
	for (int i=0; i<nparam; i++){
		start[i] = min.UserState().Value(i);
	}

	int status = min.IsValid() ? 0 : minimizer->NumOfCalls();


	if ((status==0) && options.do_master_output){
		if (min.HasCovariance()){
			MnUserCovariance cov = min.UserState().Covariance();
			std::cout << "Posterior covariance matrix has been calculated and will be stored for any later sampling steps." << std::endl;
			*made_cov = 1;
			int p=0;
			for (int i=0; i<nparam; i++){
				for (int j=0; j<nparam; j++){
					cov_output[p] = cov(i,j);
					p++;
				}
			}
		}
		else {
			*made_cov = 0;
			std::cout << "Posterior covariance matrix could not be calculated." << std::endl;
		}


		if (options.save_cov && strlen(options.save_cov)){
			if (min.HasCovariance()){
				MnUserCovariance cov = min.UserState().Covariance();
				std::cout << "Saving posterior covariance matrix estimate to file:" << options.save_cov << std::endl;
				save_covmat(options.save_cov, cov, nparam);
			}
		}
	}



	// Clean up
	delete minimizer;


	return status;
}

}
