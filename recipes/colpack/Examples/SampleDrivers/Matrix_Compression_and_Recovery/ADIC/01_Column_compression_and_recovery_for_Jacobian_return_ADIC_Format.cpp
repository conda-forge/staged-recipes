// An example of Column compression and recovery for Jacobian
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

#include "extra.h" //This .h file contains functions that are used in the below examples

int main()
{
	// s_InputFile = baseDir + <name of the input file>
	string s_InputFile; //path of the input file
	s_InputFile = baseDir;
	s_InputFile += DIR_SEPARATOR; s_InputFile += "Graphs"; s_InputFile += DIR_SEPARATOR; s_InputFile += "column-compress.mtx";
	//s_InputFile += DIR_SEPARATOR; s_InputFile += "Graphs"; s_InputFile += DIR_SEPARATOR; s_InputFile += "hess_pat.mtx";

	// Step 1: Determine sparsity structure of the Jacobian.
	// This step is done by an AD tool. For the purpose of illustration here, we read the structure from a file,
	// and store the structure in a Compressed Row Format and then ADIC format.
	unsigned int *** uip3_SparsityPattern = new unsigned int **;	//uip3_ means triple pointers of type unsigned int
	double*** dp3_Value = new double**;	//dp3_ means triple pointers of type double. Other prefixes follow the same notation
	int rowCount, columnCount;
	ConvertMatrixMarketFormat2RowCompressedFormat(s_InputFile, uip3_SparsityPattern, dp3_Value,rowCount, columnCount);

	cout<<"just for debugging purpose, display the 2 matrices: the matrix with SparsityPattern only and the matrix with Value"<<endl;
	cout<<"Matrix rowCount = "<<rowCount<<"; columnCount = "<<columnCount<<endl;
	cout<<fixed<<showpoint<<setprecision(2); //formatting output
	cout<<"(*uip3_SparsityPattern)"<<endl;
	displayCompressedRowMatrix((*uip3_SparsityPattern),rowCount, true);
	cout<<"(*dp3_Value)"<<endl;
	displayCompressedRowMatrix((*dp3_Value),rowCount);
	cout<<"Finish ConvertMatrixMarketFormat2RowCompressedFormat()"<<endl;
	Pause();

	std::list<std::set<int> > lsi_SparsityPattern;
	std::list<std::vector<double> > lvd_Value;
	ConvertRowCompressedFormat2ADIC( (*uip3_SparsityPattern) , rowCount, (*dp3_Value), lsi_SparsityPattern, lvd_Value);

	cout<<"just for debugging purpose, display the matrix in ADIC format rowCount = "<<rowCount<<endl;
	cout<<"Display lsi_SparsityPattern"<<endl;
	DisplayADICFormat_Sparsity(lsi_SparsityPattern);
	cout<<"Display lvd_Value"<<endl;
	DisplayADICFormat_Value(lvd_Value);
	cout<<"Finish ConvertRowCompressedFormat2CSR()"<<endl;
	Pause();

	//Step 2: Coloring.
	int *ip1_ColorCount = new int; //The number of distinct colors used to color the graph

	//Step 2.1: Read the sparsity pattern of the given Jacobian matrix (ADIC format)
	//and create the corresponding bipartite graph
	BipartiteGraphPartialColoringInterface *g = new BipartiteGraphPartialColoringInterface(SRC_MEM_ADIC, &lsi_SparsityPattern, columnCount);

	//Step 2.2: Do Partial-Distance-Two-Coloring the bipartite graph with the specified ordering
	g->PartialDistanceTwoColoring("SMALLEST_LAST", "COLUMN_PARTIAL_DISTANCE_TWO");

	//Step 2.3: From the coloring information, you can  get the vector of colorIDs of left or right vertices  (depend on the s_ColoringVariant that you choose)
	vector<int> vi_VertexPartialColors;
	g->GetVertexPartialColors(vi_VertexPartialColors);
	*ip1_ColorCount = g->GetRightVertexColorCount();
	cout<<"Finish GetVertexPartialColors()"<<endl;

	//Display results of step 2
	printf(" Display vi_VertexPartialColors  *ip1_ColorCount=%d \n",*ip1_ColorCount);
	displayVector(vi_VertexPartialColors);
	Pause();

	// Step 3: Obtain the Jacobian-seed matrix product.
	// This step will also be done by an AD tool. For the purpose of illustration here, the orginial matrix V
	// (for Values) is multiplied with the seed matrix S (represented as a vector of colors vi_VertexPartialColors).
	// The resulting matrix is stored in dp3_CompressedMatrix.
	double*** dp3_CompressedMatrix = new double**;
	cout<<"Start MatrixMultiplication()"<<endl;
	MatrixMultiplication_VxS__usingVertexPartialColors(lsi_SparsityPattern, lvd_Value, columnCount, vi_VertexPartialColors, *ip1_ColorCount, dp3_CompressedMatrix);
	cout<<"Finish MatrixMultiplication()"<<endl;

	displayMatrix(*dp3_CompressedMatrix,rowCount,*ip1_ColorCount);
	Pause();

	//Step 4: Recover the numerical values of the original matrix from the compressed representation.
	// The new values are store in "lvd_NewValue"
	std::list<std::vector<double> > lvd_NewValue;
	JacobianRecovery1D* jr1d = new JacobianRecovery1D;
	jr1d->RecoverD2Cln_ADICFormat(g, *dp3_CompressedMatrix, lsi_SparsityPattern, lvd_NewValue);
	cout<<"Finish Recover()"<<endl;

	DisplayADICFormat_Value(lvd_NewValue);
	Pause();

	//Check for consistency, make sure the values in the 2 matrices are the same.
	if (ADICMatricesAreEqual(lvd_Value, lvd_NewValue,0)) cout<< "lvd_Value == lvd_NewValue"<<endl;
	else cout<< "lvd_Value != lvd_NewValue"<<endl;

	Pause();

	//Deallocate memory using functions in Utilities/MatrixDeallocation.h

	free_2DMatrix(uip3_SparsityPattern, rowCount);
	uip3_SparsityPattern=NULL;

	free_2DMatrix(dp3_Value, rowCount);
	dp3_Value=NULL;

	free_2DMatrix(dp3_CompressedMatrix, rowCount);
	dp3_CompressedMatrix = NULL;

	delete ip1_ColorCount;
	ip1_ColorCount = NULL;

	delete jr1d;
	jr1d = NULL;

	delete g;
	g=NULL;

	return 0;
}
