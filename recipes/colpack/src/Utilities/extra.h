/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#ifndef EXTRA_H
#define EXTRA_H

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <iomanip>
#include <ctime>
#include <cstdlib>
#include <stdarg.h> //  support for variadic functions
//#include <cctype> //for toupper()

#include <list>
#include <set>
#include <map>
#include <string>
#include <vector>

#include "ColPackHeaders.h"

using namespace std;

/*
#include "Definitions.h"
#include "Pause.h"
*/


//Definition for dot
#define DOT 1
#define NEATO 2
#define TWOPI 3
#define CIRCO 4
#define FDP 5

/// Write out to the file ADOLC Input using Matrix Market format
/**
Input parameters:
- string s_postfix: postfix of the output file name
- int i_mode:
  - i_mode == 0: output the structure of the matrix only.
  The next 3 parameter(s) are: unsigned int ** uip2_SparsityPattern, int i_Matrix_Row, int i_Matrix_Col
  - i_mode == 1: output the structure of the matrix and values in the Compressed Matrix
  The next 6 parameter(s) are: unsigned int ** uip2_SparsityPattern, int i_Matrix_Row, int i_Matrix_Col, double** dp2_CompressedMatrix, int i_CompressedMatrix_Row, int i_CompressedMatrix_Col
  - i_mode == 2: output the structure and values of the matrix and values in the Compressed Matrix
  The next 7 parameter(s) are: unsigned int ** uip2_SparsityPattern, int i_Matrix_Row, int i_Matrix_Col, double** dp2_CompressedMatrix, int i_CompressedMatrix_Row, int i_CompressedMatrix_Col, double** dp2_Values
*/
int WriteMatrixMarket_ADOLCInput(string s_postfix, int i_mode, ...);

/// Convert a number string under Harwell-Boeing format to the format that C++ can understand
/** For example: -6.310289677458059D-07 to -6.310289677458059E-07

Essentially, this function just search backward for the letter D and replace it with E

Return value:
- 0 if letter D is not found
- 1 if latter D is found and replace by letter E
*/
int ConvertHarwellBoeingDouble(string & num_string);

string itoa(int i);

vector<string> getListOfColors(string s_InputFile);

int buildDotWithoutColor(ColPack::GraphColoringInterface &g, vector<string> &ListOfColors, string fileName);

/// Build dot file with colors, also highlight StarColoringConflicts
/**
 * !!! TO DO: improve this function so that it can detect conflicts of all coloring types
 */
int buildDotWithColor(ColPack::GraphColoringInterface &g, vector<string> &ListOfColors, string fileName);

int buildDotWithoutColor(ColPack::BipartiteGraphPartialColoringInterface &g, vector<string> &ListOfColors, string fileName);
// !!! TODO: enable conflict detection
int buildDotWithColor(ColPack::BipartiteGraphPartialColoringInterface &g, vector<string> &ListOfColors, string fileName);

// !!! TO BE BUILT
int buildDotWithoutColor(ColPack::BipartiteGraphBicoloringInterface &g, vector<string> &ListOfColors, string fileName);
// !!! TO BE BUILT
int buildDotWithColor(ColPack::BipartiteGraphBicoloringInterface &g, vector<string> &ListOfColors, string fileName);


/// Read a Row Compressed Format file
/** Read a Row Compressed Format file
Line 1: <# of rows> <# of columns> <# of non-zeros>
Line 2-(# of non-zeros + 1): <# of non-zeros in that row> <index of the 1st non-zero> <index of the 2nd non-zero> ... <index of the (# of non-zeros in that row)th non-zero>
*/
int ReadRowCompressedFormat(string s_InputFile, unsigned int *** uip3_SparsityPattern, int& rowCount, int& columnCount);

/// Test and make sure that this is a valid ordering.
/** This routine will test for:
- Duplicated vertices. If there is no duplicated vertex, this ordering is probably ok.
- Invalid vertex #. The vertex # should be between 0 and ordering.size()
*/
bool isValidOrdering(vector<int> & ordering, int offset = 0);

//Re-order the values randomly
void randomOrdering(vector<int>& ordering);

/// Convert all the characters in input to upper case, ' ', '\ t', '\ n' will be converted to '_'
string toUpper(string input);

/// Build the index struture from Row Compressed Format to Sparse Solvers Format
/**
ip2_RowIndex and ip2_ColumnIndex will be allocated memory (using malloc) and populated with the matrix structure in Sparse Solvers Format

Input:
- uip2_HessianSparsityPattern in Row Compressed Format
- ui_rowCount

Output:
- ip2_RowIndex[ui_rowCount + 1] for Sparse Solvers Format
- ip2_ColumnIndex[ ip2_RowIndex[ui_rowCount] - 1] for Sparse Solvers Format


*/
int ConvertRowCompressedFormat2SparseSolversFormat_StructureOnly(unsigned int ** uip2_HessianSparsityPattern, unsigned int ui_rowCount, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex);

/// Convert Coordinate Format to Row Compressed Format
/**
dp3_Pattern and dp3_Values will be allocated memory (using malloc) and populated with the matrix structure in Row Compressed Format

Input: (Coordinate Format)
- unsigned int* uip1_RowIndex
- unsigned int* uip1_ColumnIndex
- double* dp1_HessianValue
- int i_RowCount: number of rows of the matrix
- int i_ColumnCount: number of columns of the matrix

Output: (Row Compressed Format)
- unsigned int *** dp3_Pattern
- double*** dp3_Values

*/
int ConvertCoordinateFormat2RowCompressedFormat(unsigned int* uip1_RowIndex, unsigned int* uip1_ColumnIndex, double* dp1_HessianValue, int i_RowCount, int i_NonZeroCount, unsigned int *** dp3_Pattern, double*** dp3_Values );


/// Covert file with DIMACS format to Matrix Market format
/**
DIMACS graph format: http://www.dis.uniroma1.it/~challenge9/format.shtml#graph
Note: DIMACS graph format is for directed graph => the equivalent matrix is squared and non-systemic

Read input from file "<fileNameNoExt>.gr" (DIMACS graph format)
and generate file "<fileNameNoExt>.mtx" (Matrix Market format)
*/
void ConvertFileDIMACSFormat2MatrixMarketFormat(string fileNameNoExt);

///Read the sparse matrix from Matrix-Market-format file and convert to Row Compressed format (used by ADIC) "uip3_SparsityPattern" & "dp3_Value"
/** Read in a matrix from matrix-market format file and create a matrix stored in compressed sparse row format
The Matrix-Market-format has 3 values in each row, the row index, column index and numerical value of each nonzero.
The last 4 parameters of this routine are output parameters (unsigned int *** uip3_SparsityPattern, double*** dp3_Value,int &rowCount, int &columnCount)
*/
int ConvertMatrixMarketFormat2RowCompressedFormat(string s_InputFile, unsigned int *** uip3_SparsityPattern, double*** dp3_Value, int &rowCount, int &columnCount);

/* !!! the documentation here may not be accurate
"zero-based indexing, 3-array variation CSR format (used by ADIC)"
Does ADIC use zero-based indexing, 3-array variation CSR format any more?
//*/
/// Convert Row Compressed format (used by ADOL-C) to zero-based indexing, 3-array variation CSR format (used by ADIC)
/**
Return 0 upon successful.
*/
// !!! need to be fixed to accomodate dp2_Value parameter
int ConvertRowCompressedFormat2CSR(unsigned int ** uip2_SparsityPattern_RowCompressedFormat, int i_rowCount, int** ip_RowIndex, int** ip_ColumnIndex);

int ConvertRowCompressedFormat2ADIC(unsigned int ** uip2_SparsityPattern_RowCompressedFormat, int i_rowCount , double** dp2_Value, std::list<std::set<int> > &lsi_SparsityPattern, std::list<std::vector<double> > &lvd_Value);

/// Multiply the original sparse matrix (uip3_SparsityPattern,dp3_Value) (in compress sparse row format) with the seed matrix dp2_seed and store the result in "dp3_CompressedMatrix"
/** (*dp3_CompressedMatrix) = (*dp3_Value) * dp2_seed
*/
int MatrixMultiplication_VxS(unsigned int ** uip3_SparsityPattern, double** dp3_Value, int rowCount, int columnCount, double** dp2_seed, int colorCount, double*** dp3_CompressedMatrix);

int MatrixMultiplication_VxS__usingVertexPartialColors(std::list<std::set<int> > &lsi_SparsityPattern, std::list<std::vector<double> > &lvd_Value, int columnCount, vector<int> &vi_VertexPartialColors, int colorCount, double*** dp3_CompressedMatrix);

/// Multiply the seed matrix dp2_seed with the original sparse matrix (uip3_SparsityPattern,dp3_Value) (in compress sparse row format) and store the result in "dp3_CompressedMatrix"
/** (*dp3_CompressedMatrix) = dp2_seed * (*dp3_Value)
*/
int MatrixMultiplication_SxV(unsigned int ** uip3_SparsityPattern, double** dp3_Value, int rowCount, int columnCount, double** dp2_seed, int colorCount, double*** dp3_CompressedMatrix);

///Compare dp3_Value with dp3_NewValue and see if all the values are equal.
/**
	If (compare_exact == 0) num1 and num2 are consider equal if 0.99 <= num1/num2 <= 1.02
	If (print_all == 1) all cases of non-equal will be print out. Normally (when print_all == 0), this rountine will stop after the first non-equal.
*/
bool CompressedRowMatricesAreEqual(double** dp3_Value, double** dp3_NewValue, int rowCount, bool compare_exact = 1, bool print_all = 0);

bool ADICMatricesAreEqual(std::list<std::vector<double> >& lvd_Value, std::list<std::vector<double> >& lvd_NewValue, bool compare_exact = 1, bool print_all = 0);

///just manipulate the value of dp2_Values a little bit. Each non-zero entry in the matrix * 2 + 1.5.
int Times2Plus1point5(double** dp2_Values, int i_RowCount, int i_ColumnCount);

///just manipulate the value of dp2_Values a little bit. Each non-zero entry in the matrix * 2.
int Times2(double** dp2_Values, int i_RowCount, int i_ColumnCount);

///Allocate memory and generate random values for dp3_Value
int GenerateValues(unsigned int ** uip2_SparsityPattern, int rowCount, double*** dp3_Value);

///Allocate memory and generate random values for dp3_Value of a Symmetric Matrix.
int GenerateValuesForSymmetricMatrix(unsigned int ** uip2_SparsityPattern, int rowCount, double*** dp3_Value);

int DisplayADICFormat_Sparsity(std::list<std::set<int> > &lsi_SparsityPattern);
int DisplayADICFormat_Value(std::list<std::vector<double> > &lvd_Value);

int displayGraph(map< int, map<int,bool> > *graph, vector<int>* vi_VertexColors=NULL,int i_RunInBackground = false, int filter = DOT);
int buildDotWithoutColor(map< int, map<int,bool> > *graph, vector<string> &ListOfColors, string fileName);
int buildDotWithColor(map< int, map<int,bool> > *graph, vector<int>* vi_VertexColors, vector<string> &ListOfColors, string fileName);

#ifndef EXTRA_H_TEMPLATE_FUNCTIONS
#define EXTRA_H_TEMPLATE_FUNCTIONS

template<class T>
int displayGraph(T &g,int i_RunInBackground = false, int filter = DOT) {
  static int ranNum = rand();
  static int seq = 0;
  seq++;
  vector<string> ListOfColors = getListOfColors("");
  string fileName = "/tmp/.";
  fileName = fileName + "ColPack_"+ itoa(ranNum)+"_"+itoa(seq)+".dot";

  //build the dot file of the graph
  string m_s_VertexColoringVariant = g.GetVertexColoringVariant();
  if(m_s_VertexColoringVariant.empty() || m_s_VertexColoringVariant=="Unknown") {
    //build dot file represents graph without color info
    buildDotWithoutColor(g, ListOfColors, fileName);
  } else {
    //build dot file represents graph with color
    buildDotWithColor(g, ListOfColors, fileName);
  }

  //display the graph using xdot
  string command;
  switch (filter) {
    case NEATO: command="xdot -f neato "; break;
    case TWOPI: command="xdot -f twopi "; break;
    case CIRCO: command="xdot -f circo "; break;
    case FDP: command="xdot -f fdp "; break;
    default: command="xdot -f dot "; // case DOT
  }

  command = command + fileName;
  if(i_RunInBackground) command = command + " &";
  int i_ReturnValue = system(command.c_str());
  return i_ReturnValue;
}


///Find the difference between 2 arrays. Return 0 if there is no difference, 1 if there is at least 1 difference
template<class T>
int diffArrays(T* array1, T* array2, int rowCount, bool compare_exact = 1, bool print_all = 0) {
	double ratio = 0.;
	int none_equal_count = 0;
	for(int i = 0; i < rowCount; i++) {
	  if (compare_exact) {
	    if(array1[i]!=array2[i]) { // found a difference
	      cout<<"At index i="<<i<<"\t array1[] = "<<array1[i]<";\t array2[] = "<<array2[i]<<endl;
	      none_equal_count++;
	      if(!print_all) return 1;
	    }
	  }
	  else {
	    ratio = array1[i] / array2[i];
	    if(ratio < .99 || ratio > 1.02) { // found a difference
	      cout<<"At index i="<<i<<"\t array1[] = "<<array1[i]<";\t array2[] = "<<array2[i]<<endl;
	      none_equal_count++;
	      if(!print_all) return 1;
	    }
	  }
	}

	return none_equal_count;
}

///Find the difference between 2 vectors. Return 0 if there is no difference, 1 if there is at least 1 difference
template<class T>
int diffVectors(vector<T> array1, vector<T> array2, bool compare_exact = 1, bool print_all = 0) {
	double ratio = 0.;
	int none_equal_count = 0;

	if(array1.size() != array2.size()) {
	  cout<<"array1.size() "<<array1.size()<<" != array2.size()"<<array2.size()<<endl;
	  none_equal_count++;
	}

	int min_array_size = (array1.size() < array2.size())?array1.size():array2.size();

	for(int i = 0; i < min_array_size; i++) {
	  if (compare_exact) {
	    if(array1[i]!=array2[i]) { // found a difference
	      cout<<"At index i="<<i<<"\t array1[] = "<<array1[i]<<";\t array2[] = "<<array2[i]<<endl;
	      none_equal_count++;
	      if(!print_all) return none_equal_count;
	    }
	  }
	  else {
	    ratio = array1[i] / array2[i];
	    if(ratio < .99 || ratio > 1.02) { // found a difference
	      cout<<"At index i="<<i<<"\t array1[] = "<<array1[i]<<";\t array2[] = "<<array2[i]<<endl;
	      none_equal_count++;
	      if(!print_all) return none_equal_count;
	    }
	  }
	}

	return none_equal_count;
}

template<class T>
int freeMatrix(T** xp2_matrix, int rowCount) {
//cout<<"IN deleteM 2"<<endl<<flush;
//printf("* deleteMatrix rowCount=%d \n",rowCount);
//Pause();
	for(int i = 0; i < rowCount; i++) {
//printf("delete xp2_matrix[%d][0] = %7.2f \n", i, (float) xp2_matrix[i][0]);
		free( xp2_matrix[i]);
	}
//cout<<"MID deleteM 2"<<endl<<flush;
	free( xp2_matrix);
//cout<<"OUT deleteM 2"<<endl<<flush;
	return 0;
}

template<class T>
int freeMatrix(T*** xp3_matrix, int rowCount) {
//cout<<"IN deleteM 3"<<endl<<flush;
	freeMatrix(*xp3_matrix,rowCount);
//cout<<"MID deleteM 3"<<endl<<flush;
	free( xp3_matrix);
//cout<<"OUT deleteM 3"<<endl<<flush;
	return 0;
}

template<class T>
int deleteMatrix(T** xp2_matrix, int rowCount) {
//cout<<"IN deleteM 2"<<endl<<flush;
//printf("* deleteMatrix rowCount=%d \n",rowCount);
//Pause();
	for(int i = 0; i < rowCount; i++) {
//printf("delete xp2_matrix[%d][0] = %7.2f \n", i, (float) xp2_matrix[i][0]);
		delete xp2_matrix[i];
	}
//cout<<"MID deleteM 2"<<endl<<flush;
	delete xp2_matrix;
//cout<<"OUT deleteM 2"<<endl<<flush;
	return 0;
}

template<class T>
int deleteMatrix(T*** xp3_matrix, int rowCount) {
//cout<<"IN deleteM 3"<<endl<<flush;
	deleteMatrix(*xp3_matrix,rowCount);
//cout<<"MID deleteM 3"<<endl<<flush;
	delete xp3_matrix;
//cout<<"OUT deleteM 3"<<endl<<flush;
	return 0;
}

template<class T>
void displayCompressedRowMatrix(T** xp2_Value, int rowCount, bool structureOnly = false) {
	unsigned int estimateColumnCount = 20;
	cout<<setw(4)<<"["<<setw(3)<<"\\"<<"]       ";
	if(structureOnly) {
		for(unsigned int j=0; j < estimateColumnCount; j++) cout<<setw(4)<<j;
	}
	else {
		for(unsigned int j=0; j < estimateColumnCount; j++) cout<<setw(9)<<j;
	}
	cout<<endl;

	for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
		cout<<setw(4)<<"["<<setw(3)<<i<<"]";
		unsigned int numOfNonZeros = (unsigned int)xp2_Value[i][0];
		cout<<"  ("<<setw(3)<<numOfNonZeros<<")";
		if(structureOnly) {
			for(unsigned int j=1; j <= numOfNonZeros; j++) cout<<setw(4)<<(int)xp2_Value[i][j];
			//for(unsigned int j=1; j <= numOfNonZeros; j++) {
			//  printf("  %d",(int)xp2_Value[i][j]);
			//}
		}
		else {
			for(unsigned int j=1; j <= numOfNonZeros; j++) cout<<setw(9)<<(float)xp2_Value[i][j];
			//for(unsigned int j=1; j <= numOfNonZeros; j++) {
			//  printf("  %7.2f",(float)xp2_Value[i][j]);
			//}
		}
		cout<<endl<<flush;
	}
	cout<<endl<<endl;
}

template<class T>
void displayMatrix(T** xp2_Value, int rowCount, int columnCount, bool structureOnly = false) {
	cout<<setw(4)<<"["<<setw(3)<<"\\"<<"]";
	if(structureOnly) {
		for(unsigned int j=0; j < (unsigned int)columnCount; j++) cout<<setw(3)<<j;
	}
	else {
		for(unsigned int j=0; j < (unsigned int)columnCount; j++) cout<<setw(9)<<j;
	}
	cout<<endl;

	for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
		cout<<setw(4)<<"["<<setw(3)<<i<<"]";
		if(structureOnly) {
			for(unsigned int j=0; j < (unsigned int)columnCount; j++) cout<<setw(3)<<(bool)xp2_Value[i][j];
		}
		else {
			for(unsigned int j=0; j < (unsigned int)columnCount; j++) printf("  %7.2f",(float)xp2_Value[i][j]);
			//for(unsigned int j=0; j < (unsigned int)columnCount; j++) cout<<setw(8)<<xp2_Value[i][j];
		}
		cout<<endl<<flush;
	}
	cout<<endl<<endl;
}

template<class T>
void displayVector(T* xp2_Value, int size, bool structureOnly = false) {
	if(structureOnly) {
		for(unsigned int i=0; i < (unsigned int)size; i++) {
			cout<<setw(4)<<"["<<setw(3)<<i<<"]";
			cout<<setw(3)<<(bool)xp2_Value[i];
			cout<<endl<<flush;
		}
	}
	else {
		for(unsigned int i=0; i < (unsigned int)size; i++) {
			cout<<setw(4)<<"["<<setw(3)<<i<<"]";
			printf("  %7.2f",(float)xp2_Value[i]);
			//cout<<setw(8)<<xp2_Value[i];
			cout<<endl<<flush;
		}
	}
	cout<<endl<<endl;
}

template<class T>
int displayVector(vector<T> v) {
  for (unsigned int i=0; i < v.size(); i++) {
    cout<<setw(4)<<"["<<setw(3)<<i<<"]";
    printf("  %7.2f",(float)v[i]);
    cout<<endl<<flush;
  }
  return 0;
}


/// Used mainly to debug GraphColoringInterface::IndirectRecover() routine
template<class T>
void displayAdjacencyMatrix(vector< vector<T> > &xp2_Value, bool structureOnly = false) {
	unsigned int estimateColumnCount = 20;
	cout<<setw(4)<<"["<<setw(3)<<"\\"<<"]";
	if(structureOnly) {
		for(unsigned int j=0; j < estimateColumnCount; j++) cout<<setw(3)<<j;
	}
	else {
		for(unsigned int j=0; j < estimateColumnCount; j++) cout<<setw(9)<<j;
	}
	cout<<endl;

	unsigned int rowCount = xp2_Value.size();
	for(unsigned int i=0; i < rowCount; i++) {
		cout<<setw(4)<<"["<<setw(3)<<i<<"]";
		unsigned int numOfNonZeros = (int)xp2_Value[i].size();
		cout<<"("<<setw(5)<<numOfNonZeros<<")";
		if(structureOnly) {
			for(unsigned int j=0; j < numOfNonZeros; j++) cout<<setw(3)<<(bool)xp2_Value[i][j];
		}
		else {
			for(unsigned int j=0; j < numOfNonZeros; j++) cout<<setw(9)<<xp2_Value[i][j];
		}
		cout<<endl<<flush;
	}
	cout<<endl<<endl;
}


#endif //EXTRA_H_TEMPLATE_FUNCTIONS

#endif //EXTRA_H



