// An example for using GraphColoringInterface to generate the seed matrix for Hessian
/* How to compile this driver manually:
	To compile the code, replace the Main.cpp file in Main directory with this file
		and run "make" in ColPack installation directory. Make will generate "ColPack.exe" executable
	Run "ColPack.exe"
//*/

#include "ColPackHeaders.h"

using namespace ColPack;
using namespace std;

int main()
{
	double*** dp3_Seed = new double**;
	int *ip1_SeedRowCount = new int;
	int *ip1_SeedColumnCount = new int;
	int i_RowCount, i_MaxNonZerosInRows;

	//populate the Hessian. Uncomment one of the 2 matrices below

	/* 1x1 matrix
	i_RowCount = 1;
	i_MaxNonZerosInRows = 1;
	unsigned int **uip2_HessianSparsityPattern = new unsigned int *[i_RowCount];//[1][1]
	for(int i=0;i<1;i++) uip2_HessianSparsityPattern[i] = new unsigned int[i_MaxNonZerosInRows + 1];
	uip2_HessianSparsityPattern[0][0] = 1;		uip2_HessianSparsityPattern[0][1] = 0;
	//*/

	//* 5x5 matrix
	i_RowCount = 5;
	i_MaxNonZerosInRows = 2;
	unsigned int **uip2_HessianSparsityPattern = new unsigned int *[i_RowCount];//[5][5]
	for(int i=0;i<5;i++) uip2_HessianSparsityPattern[i] = new unsigned int[i_MaxNonZerosInRows + 1];
	uip2_HessianSparsityPattern[0][0] = 1;		uip2_HessianSparsityPattern[0][1] = 1;
	uip2_HessianSparsityPattern[1][0] = 2;		uip2_HessianSparsityPattern[1][1] = 0;		uip2_HessianSparsityPattern[1][2] = 2;
	uip2_HessianSparsityPattern[2][0] = 2;		uip2_HessianSparsityPattern[2][1] = 1;		uip2_HessianSparsityPattern[2][2] = 3;
	uip2_HessianSparsityPattern[3][0] = 2;		uip2_HessianSparsityPattern[3][1] = 2;		uip2_HessianSparsityPattern[3][2] = 4;
	uip2_HessianSparsityPattern[4][0] = 1;		uip2_HessianSparsityPattern[4][1] = 3;
	//*/


	//Step 1: Read the sparsity pattern of the given Hessian matrix (compressed sparse rows format)
	//and create the corresponding graph
	GraphColoringInterface * g = new GraphColoringInterface(SRC_MEM_ADOLC, uip2_HessianSparsityPattern, i_RowCount);

	//Step 2: Color the bipartite graph with the specified ordering
	g->Coloring("SMALLEST_LAST", "STAR");

	//Step 3: From the coloring information, create and return the seed matrix
	(*dp3_Seed) = g->GetSeedMatrix(ip1_SeedRowCount, ip1_SeedColumnCount);
	/* Notes:
	In stead of doing step 1-3, you can just call the bellow function:
		g->GenerateSeedHessian(uip2_HessianSparsityPattern, i_RowCount, dp3_Seed, ip1_SeedRowCount, ip1_SeedColumnCount, "STAR", "SMALLEST_LAST"); // this function is inside GraphColoringInterface class
	*/
	cout<<"Finish GenerateSeed()"<<endl;

	//this SECTION is just for displaying the result
	g->PrintGraphStructure();
	g->PrintVertexColors();
	g->PrintVertexColoringMetrics();
	double **Seed = *dp3_Seed;
	int rows = g->GetVertexCount();
	int cols = g->GetVertexColorCount();
	cout<<"Seed matrix: ("<<rows<<","<<cols<<")"<<endl;
	for(int i=0; i<rows; i++) {
		for(int j=0; j<cols; j++) {
			cout<<setw(6)<<Seed[i][j];
		}
		cout<<endl;
	}
	//END SECTION

	//GraphColoringInterface * g = new GraphColoringInterface();
	delete g;
	g = NULL;

	//double*** dp3_Seed = new double**;
	delete dp3_Seed;
	dp3_Seed = NULL;
	Seed = NULL;

	//int *ip1_SeedRowCount = new int;
	delete ip1_SeedRowCount;
	ip1_SeedRowCount = NULL;

	//int *ip1_SeedColumnCount = new int;
	delete ip1_SeedColumnCount;
	ip1_SeedColumnCount = NULL;

	//unsigned int **uip2_HessianSparsityPattern = new unsigned int *[i_RowCount];//[5][5]
	free_2DMatrix(uip2_HessianSparsityPattern, i_RowCount);
	uip2_HessianSparsityPattern = NULL;

	return 0;
}
