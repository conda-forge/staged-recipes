// An example of (Column) compression (by using Acyclic coloring) and indirect recovery for Hessian
/* How to compile this driver manually:
	Please make sure that "baseDir" point to the directory (folder) containing the input matrix file, and
		s_InputFile should point to the input file that you want to use
	To compile the code, replace the Main.cpp file in Main directory with this file
		and run "make" in ColPack installation directory. Make will generate "ColPack.exe" executable
	Run "ColPack.exe"

Note: If you got "symbol lookup error ... undefined symbol "
  Please make sure that your LD_LIBRARY_PATH contains libColPack.so

Return by recovery routine: a matrix
double*** dp3_NewValue;
//*/

#include "ColPackHeaders.h"

using namespace ColPack;
using namespace std;

#ifndef TOP_DIR
#define TOP_DIR "."
#endif

// baseDir should point to the directory (folder) containing the input file
string baseDir=TOP_DIR;

#include "extra.h" //This .h file contains functions that are used in the below examples:
					//ReadMM(), MatrixMultiplication...(), Times2Plus1point5(), displayMatrix() and displayCompressedRowMatrix()

int main()
{
	// s_InputFile = baseDir + <name of the input file>
	string s_InputFile; //path of the input file
	s_InputFile = baseDir;
	s_InputFile += DIR_SEPARATOR; s_InputFile += "Graphs"; s_InputFile += DIR_SEPARATOR; s_InputFile += "mtx-spear-head.mtx";

	// Step 1: Determine sparsity structure of the Jacobian.
	// This step is done by an AD tool. For the purpose of illustration here, we read the structure from a file,
	// and store the structure in a Compressed Row Format.
	unsigned int *** uip3_SparsityPattern = new unsigned int **;
	double*** dp3_Value = new double**;
	int rowCount, columnCount;
	ConvertMatrixMarketFormat2RowCompressedFormat(s_InputFile, uip3_SparsityPattern, dp3_Value,rowCount, columnCount);

	cout<<"just for debugging purpose, display the 2 matrices: the matrix with SparsityPattern only and the matrix with Value"<<endl;
	cout<<fixed<<showpoint<<setprecision(2); //formatting output
	cout<<"(*uip3_SparsityPattern)"<<endl;
	displayCompressedRowMatrix((*uip3_SparsityPattern),rowCount);
	cout<<"(*dp3_Value)"<<endl;
	displayCompressedRowMatrix((*dp3_Value),rowCount);
	cout<<"Finish ConvertMatrixMarketFormat2RowCompressedFormat()"<<endl;
	Pause();

	//Step 2: Obtain the seed matrix via coloring.
	double*** dp3_Seed = new double**;
	int *ip1_SeedRowCount = new int;
	int *ip1_SeedColumnCount = new int;
	int* ip1_ColorCount = new int; //The number of distinct colors used to color the graph

	//Step 2.1: Read the sparsity pattern of the given Hessian matrix (compressed sparse rows format)
	//and create the corresponding graph
	GraphColoringInterface *g = new GraphColoringInterface(SRC_MEM_ADOLC, *uip3_SparsityPattern, rowCount);

	//Step 2.2: Color the bipartite graph with the specified ordering
	g->Coloring("SMALLEST_LAST", "ACYCLIC_FOR_INDIRECT_RECOVERY");

	//Step 2.3 (Option 1): From the coloring information, create and return the seed matrix
	(*dp3_Seed) = g->GetSeedMatrix(ip1_SeedRowCount, ip1_SeedColumnCount);
	/* Notes:
	Step 2.3 (Option 2): From the coloring information, you can also get the vector of colorIDs of vertices
		vector<int> vi_VertexColors;
		g->GetVertexColors(vi_VertexColors);
	*/
	cout<<"Finish GenerateSeed()"<<endl;
	*ip1_ColorCount = *ip1_SeedColumnCount;

	displayMatrix(*dp3_Seed, *ip1_SeedRowCount, *ip1_SeedColumnCount);
	Pause();

	// Step 3: Obtain the Hessian-seed matrix product.
	// This step will also be done by an AD tool. For the purpose of illustration here, the orginial matrix V
	// (for Values) is multiplied with the seed matrix S. The resulting matrix is stored in dp3_CompressedMatrix.
	double*** dp3_CompressedMatrix = new double**;
	cout<<"Start MatrixMultiplication()"<<endl;
	MatrixMultiplication_VxS(*uip3_SparsityPattern, *dp3_Value, rowCount, columnCount, *dp3_Seed, *ip1_SeedColumnCount, dp3_CompressedMatrix);
	cout<<"Finish MatrixMultiplication()"<<endl;

	displayMatrix(*dp3_CompressedMatrix,rowCount,*ip1_ColorCount);
	Pause();

	//Step 4: Recover the numerical values of the original matrix from the compressed representation.
	// The new values are store in "dp3_NewValue"
	double*** dp3_NewValue = new double**;
	HessianRecovery* hr = new HessianRecovery;
	hr->IndirectRecover_RowCompressedFormat(g, *dp3_CompressedMatrix, *uip3_SparsityPattern, dp3_NewValue);
	cout<<"Finish Indirect Recover()"<<endl;

	displayCompressedRowMatrix(*dp3_NewValue,rowCount);
	Pause();

	//Check for consistency, make sure the values in the 2 matrices are the same.
	if (CompressedRowMatricesAreEqual(*dp3_Value, *dp3_NewValue, rowCount,0,1)) cout<< "*dp3_Value == dp3_NewValue"<<endl;
	else cout<< "*dp3_Value != dp3_NewValue"<<endl;


	Pause();

	//Deallocate memory using functions in Utilities/MatrixDeallocation.h

	free_2DMatrix(uip3_SparsityPattern, rowCount);
	uip3_SparsityPattern=NULL;

	free_2DMatrix(dp3_Value, rowCount);
	dp3_Value=NULL;

	delete dp3_Seed;
	dp3_Seed = NULL;

	delete ip1_SeedRowCount;
	ip1_SeedRowCount=NULL;

	delete ip1_SeedColumnCount;
	ip1_SeedColumnCount = NULL;

	free_2DMatrix(dp3_CompressedMatrix, rowCount);
	dp3_CompressedMatrix = NULL;

	delete ip1_ColorCount;
	ip1_ColorCount = NULL;

	delete hr;
	hr = NULL;

	delete dp3_NewValue;
	dp3_NewValue=NULL;

	delete g;
	g=NULL;

	return 0;
}
