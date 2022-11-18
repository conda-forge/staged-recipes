// An example of Bidirectional compression and recovery for Jacobian using Star Bicoloring
/* How to compile this driver manually:
	Please make sure that "baseDir" point to the directory (folder) containing the input matrix file, and
		s_InputFile should point to the input file that you want to use
	To compile the code, replace the Main.cpp file in Main directory with this file
		and run "make" in ColPack installation directory. Make will generate "ColPack.exe" executable
	Run "ColPack.exe"

Note: If you got "symbol lookup error ... undefined symbol "
  Please make sure that your LD_LIBRARY_PATH contains libColPack.so
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
	s_InputFile += DIR_SEPARATOR; s_InputFile += "Graphs"; s_InputFile += DIR_SEPARATOR; s_InputFile += "column-compress.mtx";

	// Step 1: Determine sparsity structure of the Jacobian.
	// This step is done by an AD tool. For the purpose of illustration here, we read the structure from a file,
	// and store the structure in a Compressed Row Format.
	unsigned int *** uip3_SparsityPattern = new unsigned int **;	//uip3_ means triple pointers of type unsigned int
	double*** dp3_Value = new double**;	//dp3_ means triple pointers of type double. Other prefixes follow the same notation
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

	//Step 2: Obtain the seed matrices via Star Bicoloring.
	double*** dp3_LeftSeed = new double**;
	int *ip1_LeftSeedRowCount = new int;
	int *ip1_LeftSeedColumnCount = new int;
	double*** dp3_RightSeed = new double**;
	int *ip1_RightSeedRowCount = new int;
	int *ip1_RightSeedColumnCount = new int;

	//Step 2.1: Read the sparsity pattern of the given Jacobian matrix (compressed sparse rows format)
	//and create the corresponding bipartite graph
	BipartiteGraphBicoloringInterface *g = new BipartiteGraphBicoloringInterface(SRC_MEM_ADOLC, *uip3_SparsityPattern, rowCount, columnCount);

	//Step 2.2: Color the graph based on the specified ordering and (Star) Bicoloring
	g->Bicoloring("SMALLEST_LAST", "IMPLICIT_COVERING__STAR_BICOLORING");

	//Step 2.3 (Option 1): From the coloring information, create and return the Left and Right seed matrices
	(*dp3_LeftSeed) = g->GetLeftSeedMatrix(ip1_LeftSeedRowCount, ip1_LeftSeedColumnCount );
	(*dp3_RightSeed) = g->GetRightSeedMatrix(ip1_RightSeedRowCount, ip1_RightSeedColumnCount );
	/* Notes:
	Step 2.3 (Option 2): From the coloring information, you can also get the vector of colorIDs of left and right vertices
		vector<int> vi_LeftVertexColors;
		g->GetLeftVertexColors(vi_LeftVertexColors);
		vector<int> RightVertexColors;
		g->GetRightVertexColors_Transformed(RightVertexColors);
	*/
	cout<<"Finish GenerateSeed()"<<endl;

	//Display results of step 2
	printf(" dp3_LeftSeed %d x %d", *ip1_LeftSeedRowCount, *ip1_LeftSeedColumnCount);
	displayMatrix(*dp3_LeftSeed, *ip1_LeftSeedRowCount, *ip1_LeftSeedColumnCount);
	printf(" dp3_RightSeed %d x %d", *ip1_RightSeedRowCount, *ip1_RightSeedColumnCount);
	displayMatrix(*dp3_RightSeed, *ip1_RightSeedRowCount, *ip1_RightSeedColumnCount);
	Pause();

	// Step 3: Obtain the Jacobian-RightSeed and LeftSeed-Jacobian matrix products.
	// This step will also be done by an AD tool. For the purpose of illustration here:
	// - The left seed matrix LS is multiplied with the orginial matrix V (for Values).
	//   The resulting matrix is stored in dp3_LeftCompressedMatrix.
	// - The orginial matrix V (for Values) is multiplied with the right seed matrix RS.
	//   The resulting matrix is stored in dp3_RightCompressedMatrix.
	double*** dp3_LeftCompressedMatrix = new double**;
	double*** dp3_RightCompressedMatrix = new double**;
	cout<<"Start MatrixMultiplication() for both direction (left and right)"<<endl;
	MatrixMultiplication_SxV(*uip3_SparsityPattern, *dp3_Value, rowCount, columnCount, *dp3_LeftSeed, *ip1_LeftSeedRowCount, dp3_LeftCompressedMatrix);
	MatrixMultiplication_VxS(*uip3_SparsityPattern, *dp3_Value, rowCount, columnCount, *dp3_RightSeed, *ip1_RightSeedColumnCount, dp3_RightCompressedMatrix);
	cout<<"Finish MatrixMultiplication()"<<endl;

	displayMatrix(*dp3_RightCompressedMatrix,rowCount,*ip1_RightSeedColumnCount);
	displayMatrix(*dp3_LeftCompressedMatrix,*ip1_LeftSeedRowCount, columnCount);
	Pause();

	//Step 4: Recover the numerical values of the original matrix from the compressed representation.
	// The new values are store in "dp3_NewValue"
	double*** dp3_NewValue = new double**;
	JacobianRecovery2D* jr2d = new JacobianRecovery2D;
	int rowCount_for_dp3_NewValue = jr2d->DirectRecover_RowCompressedFormat_unmanaged(g, *dp3_LeftCompressedMatrix, *dp3_RightCompressedMatrix, *uip3_SparsityPattern, dp3_NewValue);
	/* RecoverD2Cln_RowCompressedFormat_unmanaged is called instead of RecoverD2Cln_RowCompressedFormat so that
	we could manage the memory deallocation for dp3_NewValue by ourselves.
	This way, we can reuse (*dp3_NewValue) to store new values if RecoverD2Cln_RowCompressedFormat...() need to be called again.
	//*/

	cout<<"Finish Recover()"<<endl;

	displayCompressedRowMatrix(*dp3_NewValue,rowCount);
	Pause();

	//Check for consistency, make sure the values in the 2 matrices are the same.
	if (CompressedRowMatricesAreEqual(*dp3_Value, *dp3_NewValue, rowCount,0)) cout<< "*dp3_Value == dp3_NewValue"<<endl;
	else cout<< "*dp3_Value != dp3_NewValue"<<endl;

	Pause();

	/* Let say that we have new matrices with the same sparsity structure (only the values changed),
	 We can take advantage of the memory already allocated to (*dp3_NewValue) and use (*dp3_NewValue) to stored the new values
	 by calling DirectRecover_RowCompressedFormat_usermem recovery function.
	 This function works in the same way as DirectRecover_RowCompressedFormat_unmanaged except that the memory for (*dp3_NewValue)
	 is reused and therefore, takes less time than the _unmanaged counterpart.
	 //*/
	for(int i=0; i<3;i++) {
	  jr2d->DirectRecover_RowCompressedFormat_usermem(g, *dp3_LeftCompressedMatrix, *dp3_RightCompressedMatrix, *uip3_SparsityPattern, dp3_NewValue);
	}

	//Deallocate memory for 2-dimensional array (*dp3_NewValue)
	for(int i=0; i<rowCount;i++) {
	  free((*dp3_NewValue)[i]);
	}
	free(*dp3_NewValue);

	//Deallocate memory using functions in Utilities/MatrixDeallocation.h

	delete jr2d;
	jr2d = NULL;

	delete dp3_NewValue;
	dp3_NewValue = NULL;

	free_2DMatrix(dp3_RightCompressedMatrix, rowCount);
	dp3_RightCompressedMatrix = NULL;

	free_2DMatrix(dp3_LeftCompressedMatrix, *ip1_LeftSeedRowCount);
	dp3_LeftCompressedMatrix = NULL;

	delete dp3_RightSeed;
	dp3_RightSeed = NULL;

	delete ip1_RightSeedColumnCount;
	ip1_RightSeedColumnCount = NULL;

	delete ip1_RightSeedRowCount;
	ip1_RightSeedRowCount = NULL;

	delete dp3_LeftSeed;
	dp3_LeftSeed = NULL;

	delete ip1_LeftSeedColumnCount;
	ip1_LeftSeedColumnCount = NULL;

	delete ip1_LeftSeedRowCount;
	ip1_LeftSeedRowCount = NULL;

	free_2DMatrix(dp3_Value, rowCount);
	dp3_Value = NULL;

	free_2DMatrix(uip3_SparsityPattern, rowCount);
	dp3_Value = NULL;

	delete g;
	g=NULL;

	return 0;
}
