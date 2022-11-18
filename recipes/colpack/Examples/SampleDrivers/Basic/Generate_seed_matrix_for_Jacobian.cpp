// An example for using BipartiteGraphPartialColoringInterface to generate the seed matrix for Jacobian
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
	int i_RowCount, i_ColumnCount, i_MaxNonZerosInRows;

	//populate the Jacobian. Uncomment one of the 2 matrices below
	/* 1x1 matrix
	i_RowCount = 1;
	i_ColumnCount = 1;
	i_MaxNonZerosInRows = 1;
	unsigned int **uip2_JacobianSparsityPattern = new unsigned int *[i_RowCount];//[1][1]
	for(int i=0;i<i_RowCount;i++) uip2_JacobianSparsityPattern[i] = new unsigned int[i_MaxNonZerosInRows + 1];
	uip2_JacobianSparsityPattern[0][0] = 1;		uip2_JacobianSparsityPattern[0][1] = 0;
	//*/

	//* 32x9 matrix
	i_RowCount = 32;
	i_ColumnCount = 9;
	i_MaxNonZerosInRows = 3;
	unsigned int **uip2_JacobianSparsityPattern = new unsigned int *[i_RowCount];//[32][9]
	for(int i=0;i<i_RowCount;i++) uip2_JacobianSparsityPattern[i] = new unsigned int[i_MaxNonZerosInRows + 1];
	uip2_JacobianSparsityPattern[0][0] = 0;
	uip2_JacobianSparsityPattern[1][0] = 1;		uip2_JacobianSparsityPattern[1][1] = 0;
	uip2_JacobianSparsityPattern[2][0] = 1;		uip2_JacobianSparsityPattern[2][1] = 1;
	uip2_JacobianSparsityPattern[3][0] = 1;		uip2_JacobianSparsityPattern[3][1] = 2;
	uip2_JacobianSparsityPattern[4][0] = 1;		uip2_JacobianSparsityPattern[4][1] = 0;
	uip2_JacobianSparsityPattern[5][0] = 3;		uip2_JacobianSparsityPattern[5][1] = 0;		uip2_JacobianSparsityPattern[5][2] = 1;		uip2_JacobianSparsityPattern[5][3] = 3;
	uip2_JacobianSparsityPattern[6][0] = 3;		uip2_JacobianSparsityPattern[6][1] = 1;		uip2_JacobianSparsityPattern[6][2] = 2;		uip2_JacobianSparsityPattern[6][3] = 4;
	uip2_JacobianSparsityPattern[7][0] = 2;		uip2_JacobianSparsityPattern[7][1] = 2;		uip2_JacobianSparsityPattern[7][2] = 5;
	uip2_JacobianSparsityPattern[8][0] = 1;		uip2_JacobianSparsityPattern[8][1] = 3;
	uip2_JacobianSparsityPattern[9][0] = 3;		uip2_JacobianSparsityPattern[9][1] = 3;		uip2_JacobianSparsityPattern[9][2] = 4;		uip2_JacobianSparsityPattern[9][3] = 6;
	uip2_JacobianSparsityPattern[10][0] = 3;	uip2_JacobianSparsityPattern[10][1] = 4;		uip2_JacobianSparsityPattern[10][2] = 5;		uip2_JacobianSparsityPattern[10][3] = 7;
	uip2_JacobianSparsityPattern[11][0] = 2;	uip2_JacobianSparsityPattern[11][1] = 5;		uip2_JacobianSparsityPattern[11][2] = 8;
	uip2_JacobianSparsityPattern[12][0] = 1;	uip2_JacobianSparsityPattern[12][1] = 6;
	uip2_JacobianSparsityPattern[13][0] = 2;	uip2_JacobianSparsityPattern[13][1] = 6;		uip2_JacobianSparsityPattern[13][2] = 7;
	uip2_JacobianSparsityPattern[14][0] = 2;	uip2_JacobianSparsityPattern[14][1] = 7;		uip2_JacobianSparsityPattern[14][2] = 8;
	uip2_JacobianSparsityPattern[15][0] = 1;	uip2_JacobianSparsityPattern[15][1] = 8;
	uip2_JacobianSparsityPattern[16][0] = 1;	uip2_JacobianSparsityPattern[16][1] = 0;
	uip2_JacobianSparsityPattern[17][0] = 2;	uip2_JacobianSparsityPattern[17][1] = 0;		uip2_JacobianSparsityPattern[17][2] = 1;
	uip2_JacobianSparsityPattern[18][0] = 2;	uip2_JacobianSparsityPattern[18][1] = 1;		uip2_JacobianSparsityPattern[18][2] = 2;
	uip2_JacobianSparsityPattern[19][0] = 1;	uip2_JacobianSparsityPattern[19][1] = 2;
	uip2_JacobianSparsityPattern[20][0] = 2;	uip2_JacobianSparsityPattern[20][1] = 0;		uip2_JacobianSparsityPattern[20][2] = 3;
	uip2_JacobianSparsityPattern[21][0] = 3;	uip2_JacobianSparsityPattern[21][1] = 1;		uip2_JacobianSparsityPattern[21][2] = 3;		uip2_JacobianSparsityPattern[21][3] = 4;
	uip2_JacobianSparsityPattern[22][0] = 3;	uip2_JacobianSparsityPattern[22][1] = 2;		uip2_JacobianSparsityPattern[22][2] = 4;		uip2_JacobianSparsityPattern[22][3] = 5;
	uip2_JacobianSparsityPattern[23][0] = 1;	uip2_JacobianSparsityPattern[23][1] = 5;
	uip2_JacobianSparsityPattern[24][0] = 2;	uip2_JacobianSparsityPattern[24][1] = 3;		uip2_JacobianSparsityPattern[24][2] = 6;
	uip2_JacobianSparsityPattern[25][0] = 3;	uip2_JacobianSparsityPattern[25][1] = 4;		uip2_JacobianSparsityPattern[25][2] = 6;		uip2_JacobianSparsityPattern[25][3] = 7;
	uip2_JacobianSparsityPattern[26][0] = 3;	uip2_JacobianSparsityPattern[26][1] = 5;		uip2_JacobianSparsityPattern[26][2] = 7;		uip2_JacobianSparsityPattern[26][3] = 8;
	uip2_JacobianSparsityPattern[27][0] = 1;	uip2_JacobianSparsityPattern[27][1] = 8;
	uip2_JacobianSparsityPattern[28][0] = 1;	uip2_JacobianSparsityPattern[28][1] = 6;
	uip2_JacobianSparsityPattern[29][0] = 1;	uip2_JacobianSparsityPattern[29][1] = 7;
	uip2_JacobianSparsityPattern[30][0] = 1;	uip2_JacobianSparsityPattern[30][1] = 8;
	uip2_JacobianSparsityPattern[31][0] = 0;
	//*/

	//Step 1: Read the sparsity pattern of the given Jacobian matrix (compressed sparse rows format)
	//and create the corresponding bipartite graph
	BipartiteGraphPartialColoringInterface * g = new BipartiteGraphPartialColoringInterface(SRC_MEM_ADOLC, uip2_JacobianSparsityPattern, i_RowCount, i_ColumnCount);

	//Step 2: Do Partial-Distance-Two-Coloring the bipartite graph with the specified ordering
	g->PartialDistanceTwoColoring( "SMALLEST_LAST", "COLUMN_PARTIAL_DISTANCE_TWO");

	//Step 3: From the coloring information, create and return the seed matrix
	(*dp3_Seed) = g->GetSeedMatrix(ip1_SeedRowCount, ip1_SeedColumnCount);
	/* Notes:
	In stead of doing step 1-3, you can just call the bellow function:
		g->GenerateSeedJacobian(uip2_JacobianSparsityPattern, i_RowCount,i_ColumnCount, dp3_Seed, ip1_SeedRowCount, ip1_SeedColumnCount, "COLUMN_PARTIAL_DISTANCE_TWO", "SMALLEST_LAST"); // compress columns. This function is inside BipartiteGraphPartialColoringInterface class
	*/
	cout<<"Finish GenerateSeed()"<<endl;

	//this SECTION is just for displaying the result
	g->PrintBipartiteGraph();
	g->PrintColumnPartialColors();
	g->PrintColumnPartialColoringMetrics();
	double **RSeed = *dp3_Seed;
	int rows = g->GetColumnVertexCount();
	int cols = g->GetRightVertexColorCount();
	cout<<"Right Seed matrix: ("<<rows<<","<<cols<<")"<<endl;
	for(int i=0; i<rows; i++) {
		for(int j=0; j<cols; j++) {
			cout<<setw(6)<<RSeed[i][j];
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
	RSeed = NULL;

	//int *ip1_SeedRowCount = new int;
	delete ip1_SeedRowCount;
	ip1_SeedRowCount = NULL;

	//int *ip1_SeedColumnCount = new int;
	delete ip1_SeedColumnCount;
	ip1_SeedColumnCount = NULL;

	//unsigned int **uip2_HessianSparsityPattern = new unsigned int *[i_RowCount];//[5][5]
	free_2DMatrix(uip2_JacobianSparsityPattern, i_RowCount);
	uip2_JacobianSparsityPattern = NULL;

	return 0;
}
