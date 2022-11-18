/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "ColPackHeaders.h"

using namespace std;
//#define DEBUG 5103
namespace ColPack
{

	int HessianRecovery::DirectRecover_RowCompressedFormat_usermem(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, double*** dp3_HessianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetVertexCount();
		int colorCount = g->GetVertexColorCount();
		//cout<<"colorCount="<<colorCount<<endl;
		vector<int> vi_VertexColors;
		g->GetVertexColors(vi_VertexColors);

		//Do (column-)color statistic for each row, i.e., see how many elements in that row has color 0, color 1 ...
		int** colorStatistic = new int*[rowCount];	//color statistic for each row. For example, colorStatistic[0] is color statistic for row 0
													//If row 0 has 5 columns with color 3 => colorStatistic[0][3] = 5;
		//Allocate memory for colorStatistic[rowCount][colorCount] and initilize the matrix
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			colorStatistic[i] = new int[colorCount];
			for(unsigned int j=0; j < (unsigned int)colorCount; j++) colorStatistic[i][j] = 0;
		}

		//populate colorStatistic
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			int numOfNonZeros = uip2_HessianSparsityPattern[i][0];
			for(unsigned int j=1; j <= (unsigned int)numOfNonZeros; j++) {
				//non-zero in the Hessian: [i][uip2_HessianSparsityPattern[i][j]]
				//color of that column: vi_VertexColors[uip2_HessianSparsityPattern[i][j]]
				colorStatistic[i][vi_VertexColors[uip2_HessianSparsityPattern[i][j]]]++;
			}
		}

		//Now, go to the main part, recover the values of non-zero entries in the Hessian
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			unsigned int numOfNonZeros = uip2_HessianSparsityPattern[i][0];
			for(unsigned int j=1; j <= numOfNonZeros; j++) {
				if(i == uip2_HessianSparsityPattern[i][j]) { // the non-zero is in the diagonal of the matrix
					(*dp3_HessianValue)[i][j] = dp2_CompressedMatrix[i][vi_VertexColors[i]];
					//printf("Recover diagonal (*dp3_HessianValue)[%d][%d] = %f from dp2_CompressedMatrix[%d][%d] \n", i, j, dp2_CompressedMatrix[i][vi_VertexColors[i]], i, vi_VertexColors[i]);
				}
				else {// i != uip2_HessianSparsityPattern[i][j] // the non-zero is NOT in the diagonal of the matrix
					if(colorStatistic[i][vi_VertexColors[uip2_HessianSparsityPattern[i][j]]]==1) {
						(*dp3_HessianValue)[i][j] = dp2_CompressedMatrix[i][vi_VertexColors[uip2_HessianSparsityPattern[i][j]]];
						//printf("Recover (*dp3_HessianValue)[%d][%d] = %f from dp2_CompressedMatrix[%d][%d] \n", i, j, dp2_CompressedMatrix[i][vi_VertexColors[uip2_HessianSparsityPattern[i][j]]], i, vi_VertexColors[uip2_HessianSparsityPattern[i][j]]);
					}
					else {
						(*dp3_HessianValue)[i][j] = dp2_CompressedMatrix[uip2_HessianSparsityPattern[i][j]][vi_VertexColors[i]];
						//printf("Recover (*dp3_HessianValue)[%d][%d] = %f from dp2_CompressedMatrix[%d][%d] \n", i, j, dp2_CompressedMatrix[uip2_HessianSparsityPattern[i][j]][vi_VertexColors[i]], uip2_HessianSparsityPattern[i][j], vi_VertexColors[i]);
					}
				}
			}
		}

		free_2DMatrix(colorStatistic, rowCount);
		colorStatistic = NULL;

		return (rowCount);
	}

	int HessianRecovery::DirectRecover_RowCompressedFormat_unmanaged(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, double*** dp3_HessianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetVertexCount();

		//allocate memory for *dp3_HessianValue. The dp3_HessianValue and uip2_HessianSparsityPattern matrices should have the same size
		*dp3_HessianValue = (double**) malloc(rowCount * sizeof(double*));
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			unsigned int numOfNonZeros = uip2_HessianSparsityPattern[i][0];
			(*dp3_HessianValue)[i] = (double*) malloc( (numOfNonZeros+1) * sizeof(double) );
			(*dp3_HessianValue)[i][0] = numOfNonZeros; //initialize value of the 1st entry
			for(unsigned int j=1; j <= numOfNonZeros; j++) (*dp3_HessianValue)[i][j] = 0.; //initialize value of other entries
		}

		return DirectRecover_RowCompressedFormat_usermem(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, dp3_HessianValue);
	}

	int HessianRecovery::DirectRecover_RowCompressedFormat(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, double*** dp3_HessianValue) {

		int returnValue = DirectRecover_RowCompressedFormat_unmanaged(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, dp3_HessianValue);

		if(AF_available) reset();

		AF_available = true;
		i_AF_rowCount = g->GetVertexCount();
		dp2_AF_Value = *dp3_HessianValue;

		return (returnValue);
	}


	int HessianRecovery::DirectRecover_SparseSolversFormat_usermem(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_HessianValue, unsigned int numOfNonZerosInHessianValue) {

		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetVertexCount();
		int colorCount = g->GetVertexColorCount();
		//cout<<"colorCount="<<colorCount<<endl;
		vector<int> vi_VertexColors;
		g->GetVertexColors(vi_VertexColors);

		//g->PrintGraph();

		//Making the array indices to start at 0 instead of 1
		for(unsigned int i=0; i <= (unsigned int) rowCount ; i++) {
		  (*ip2_RowIndex)[i]--;
		}
		for(unsigned int i=0; i < numOfNonZerosInHessianValue; i++) {
		  (*ip2_ColumnIndex)[i]--;
		}

		//Do (column-)color statistic for each row, i.e., see how many elements in that row has color 0, color 1 ...
		int** colorStatistic = new int*[rowCount];	//color statistic for each row. For example, colorStatistic[0] is color statistic for row 0
													//If row 0 has 5 columns with color 3 => colorStatistic[0][3] = 5;
		//Allocate memory for colorStatistic[rowCount][colorCount] and initilize the matrix
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			colorStatistic[i] = new int[colorCount];
			for(unsigned int j=0; j < (unsigned int)colorCount; j++) colorStatistic[i][j] = 0;
		}

		//populate colorStatistic
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			int numOfNonZeros = uip2_HessianSparsityPattern[i][0];
			for(unsigned int j=1; j <= (unsigned int)numOfNonZeros; j++) {
				//non-zero in the Hessian: [i][uip2_HessianSparsityPattern[i][j]]
				//color of that column: vi_VertexColors[uip2_HessianSparsityPattern[i][j]]
				colorStatistic[i][vi_VertexColors[uip2_HessianSparsityPattern[i][j]]]++;
			}
		}


		//Now, go to the main part, recover the values of non-zero entries in the Hessian
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			unsigned int numOfNonZeros = uip2_HessianSparsityPattern[i][0];
			unsigned int offset = 0;
			//printf("\ti=%d, \t NumOfNonzeros=%d,\t  \n",i,numOfNonZeros);
			for(unsigned int j=1; j <= numOfNonZeros; j++) {
				if (i > uip2_HessianSparsityPattern[i][j]) {
				  offset++;
				  continue;
				}
				else if(i == uip2_HessianSparsityPattern[i][j]) { // the non-zero is in the diagonal of the matrix
					(*dp2_HessianValue)[(*ip2_RowIndex)[i] + j - offset - 1] = dp2_CompressedMatrix[i][vi_VertexColors[i]];
					//printf("DIAGONAL Recover (*dp2_HessianValue)[%d] = %f from dp2_CompressedMatrix[%d][%d] \n", (*ip2_RowIndex)[i] + j - offset - 1, (*dp2_HessianValue)[(*ip2_RowIndex)[i] + j - 1],i,vi_VertexColors[i]);
					//printf("\t (*ip2_RowIndex)[i = %d] = %d, j = %d, offset = %d \n", i, (*ip2_RowIndex)[i], j, offset);
				}
				else {// i != uip2_HessianSparsityPattern[i][j] // the non-zero is NOT in the diagonal of the matrix
					if(colorStatistic[i][vi_VertexColors[uip2_HessianSparsityPattern[i][j]]]==1) {
						(*dp2_HessianValue)[(*ip2_RowIndex)[i] + j - offset - 1] = dp2_CompressedMatrix[i][vi_VertexColors[uip2_HessianSparsityPattern[i][j]]];
					  //printf("Recover (*dp2_HessianValue)[%d] = %f from dp2_CompressedMatrix[%d][%d] \n", (*ip2_RowIndex)[i] + j - offset - 1, (*dp2_HessianValue)[(*ip2_RowIndex)[i] + j - 1], i , vi_VertexColors[uip2_HessianSparsityPattern[i][j]]);
					}
					else {
						(*dp2_HessianValue)[(*ip2_RowIndex)[i] + j - offset - 1] = dp2_CompressedMatrix[uip2_HessianSparsityPattern[i][j]][vi_VertexColors[i]];
					  //printf("Recover (*dp2_HessianValue)[%d] = %f from dp2_CompressedMatrix[%d][%d] \n", (*ip2_RowIndex)[i] + j - offset - 1, (*dp2_HessianValue)[(*ip2_RowIndex)[i] + j - 1], uip2_HessianSparsityPattern[i][j], vi_VertexColors[i]);
					}
				}
			}
		}

		free_2DMatrix(colorStatistic, rowCount);
		colorStatistic = NULL;

		//Making the array indices to start at 1 instead of 0 to conform with the Intel MKL sparse storage scheme for the direct sparse solvers
		for(unsigned int i=0; i <= (unsigned int) rowCount ; i++) {
		  (*ip2_RowIndex)[i]++;
		}
		for(unsigned int i=0; i < numOfNonZerosInHessianValue; i++) {
		  (*ip2_ColumnIndex)[i]++;
		}

		return (rowCount);
	}

	int HessianRecovery::DirectRecover_SparseSolversFormat_unmanaged(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_HessianValue, unsigned int numOfNonZerosInHessianValue) {

		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetVertexCount();

		if (numOfNonZerosInHessianValue < 1) {
		  numOfNonZerosInHessianValue = ConvertRowCompressedFormat2SparseSolversFormat_StructureOnly(uip2_HessianSparsityPattern, rowCount, ip2_RowIndex, ip2_ColumnIndex);

		  //Making the array indices to start at 1 instead of 0 to conform with the Intel MKL sparse storage scheme for the direct sparse solvers
		  for(unsigned int i=0; i <= (unsigned int) rowCount ; i++) {
		    (*ip2_RowIndex)[i]++;
		  }
		  for(unsigned int i=0; i < numOfNonZerosInHessianValue; i++) {
		    (*ip2_ColumnIndex)[i]++;
		  }
		}

		//cout<<"allocate memory for *dp2_HessianValue rowCount="<<rowCount<<endl;
		//printf("i=%d\t numOfNonZerosInHessianValue=%d \n", i, numOfNonZerosInHessianValue);
		(*dp2_HessianValue) = (double*) malloc(numOfNonZerosInHessianValue * sizeof(double)); //allocate memory for *dp2_JacobianValue.
		for(unsigned int i=0; i < numOfNonZerosInHessianValue; i++) (*dp2_HessianValue)[i] = 0.; //initialize value of other entries

		int returnValue = DirectRecover_SparseSolversFormat_usermem(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, ip2_RowIndex, ip2_ColumnIndex, dp2_HessianValue, numOfNonZerosInHessianValue);

		return returnValue;
	}

	int HessianRecovery::DirectRecover_SparseSolversFormat(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_HessianValue) {
		int returnValue = DirectRecover_SparseSolversFormat_unmanaged(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, ip2_RowIndex, ip2_ColumnIndex, dp2_HessianValue);

		if(SSF_available) {
			//cout<<"SSF_available="<<SSF_available<<endl; Pause();
			reset();
		}

		SSF_available = true;
		i_SSF_rowCount = g->GetVertexCount();
		ip_SSF_RowIndex = *ip2_RowIndex;
		ip_SSF_ColumnIndex = *ip2_ColumnIndex;
		dp_SSF_Value = *dp2_HessianValue;

		return (returnValue);
	}

/*
	int HessianRecovery::DirectRecover_CoordinateFormat_vectors_OMP(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, vector<unsigned int> &RowIndex, vector<unsigned int> &ColumnIndex, vector<double> &HessianValue) {
		int rowCount = g->GetVertexCount();
		int colorCount = g->GetVertexColorCount();
		//cout<<"colorCount="<<colorCount<<endl;
		vector<int> vi_VertexColors;
		g->GetVertexColors(vi_VertexColors);

		//Do (column-)color statistic for each row, i.e., see how many elements in that row has color 0, color 1 ...
		int** colorStatistic = new int*[rowCount];	//color statistic for each row. For example, colorStatistic[0] is color statistic for row 0
													//If row 0 has 5 columns with color 3 => colorStatistic[0][3] = 5;
		//Allocate memory for colorStatistic[rowCount][colorCount] and initilize the matrix
		#pragma omp parallel for default(none) schedule(static) shared(colorStatistic, colorCount, rowCount)
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			colorStatistic[i] = new int[colorCount];
			for(unsigned int j=0; j < (unsigned int)colorCount; j++) colorStatistic[i][j] = 0;
		}

		//populate colorStatistic
		#pragma omp parallel for default(none) schedule(static) shared(rowCount, uip2_HessianSparsityPattern, colorStatistic, vi_VertexColors)
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			int numOfNonZeros = uip2_HessianSparsityPattern[i][0];
			for(unsigned int j=1; j <= (unsigned int)numOfNonZeros; j++) {
				//non-zero in the Hessian: [i][uip2_HessianSparsityPattern[i][j]]
				//color of that column: vi_VertexColors[uip2_HessianSparsityPattern[i][j]]
				colorStatistic[i][vi_VertexColors[uip2_HessianSparsityPattern[i][j]]]++;
			}
		}

		int* row_size = new int[rowCount];
		int total_length=0;
		row_size[0]=0;

		#pragma omp parallel for default(none) schedule(static) shared(rowCount,row_size, uip2_HessianSparsityPattern) reduction(+:total_length)
		// Find out the number of elements in each  rows. Note: row_size[1] will has the number of elements in the first row (!!!NOT the 2nd row)
		for(unsigned int i=0; i < (unsigned int)rowCount-1; i++) {
			unsigned int numOfNonZeros = uip2_HessianSparsityPattern[i][0];
			int rsize=0;
			for(unsigned int j=1; j <= numOfNonZeros; j++) {
			  if(uip2_HessianSparsityPattern[i][j]<i) continue;
			  rsize++;
			}
			total_length = total_length + rsize;
			row_size[i+1]=rsize;
		}
		for(unsigned int j=1; j <= uip2_HessianSparsityPattern[rowCount-1][0]; j++) {
		  if(uip2_HessianSparsityPattern[rowCount-1][j]<rowCount-1) continue;
		  total_length++;
		}

		// Allocate memory for RowIndex,  ColumnIndex and HessianValue. Also modify row_size
		#pragma omp sections
		{
		  #pragma omp section
		  {
		    RowIndex.resize(total_length);
		  }
		  #pragma omp section
		  {
		    ColumnIndex.resize(total_length);
		  }
		  #pragma omp section
		  {
		    HessianValue.resize(total_length);
		  }
		  #pragma omp section
		  {
		    //Modify row_size so that each element will keep the starting index of RowIndex,  ColumnIndex and HessianValue
		    for(unsigned int i=1; i < (unsigned int)rowCount; i++) {
		      row_size[i] += row_size[i-1];
		    }
		  }
		}

		//Now, go to the main part, recover the values of non-zero entries in the Hessian
		//!!! Working
		#pragma omp parallel for default(none) schedule(static) shared(rowCount, uip2_HessianSparsityPattern, HessianValue, RowIndex, ColumnIndex, dp2_CompressedMatrix, vi_VertexColors, colorStatistic, row_size)
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			unsigned int numOfNonZeros = uip2_HessianSparsityPattern[i][0];
			int index = 0;
			for(unsigned int j=1; j <= numOfNonZeros; j++) {
				if(uip2_HessianSparsityPattern[i][j]<i) continue;

				if(i == uip2_HessianSparsityPattern[i][j]) { // the non-zero is in the diagonal of the matrix
					HessianValue.push_back(dp2_CompressedMatrix[i][vi_VertexColors[i]]);
				}
				else {// i != uip2_HessianSparsityPattern[i][j] // the non-zero is NOT in the diagonal of the matrix
					if(colorStatistic[i][vi_VertexColors[uip2_HessianSparsityPattern[i][j]]]==1) {
						HessianValue[row_size[i]+index] =dp2_CompressedMatrix[i][vi_VertexColors[uip2_HessianSparsityPattern[i][j]]];
					}
					else {
						HessianValue[row_size[i]+index] =dp2_CompressedMatrix[uip2_HessianSparsityPattern[i][j]][vi_VertexColors[i]];
					}
				}
				RowIndex[row_size[i]+index] = i;
				ColumnIndex[row_size[i]+index] = uip2_HessianSparsityPattern[i][j];
				index++;
			}
		}

		free_2DMatrix(colorStatistic, rowCount);
		colorStatistic = NULL;

		return (RowIndex.size());
	}
*/
	int HessianRecovery::DirectRecover_CoordinateFormat_vectors(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, vector<unsigned int> &RowIndex, vector<unsigned int> &ColumnIndex, vector<double> &HessianValue) {
		int rowCount = g->GetVertexCount();
		int colorCount = g->GetVertexColorCount();
		//cout<<"colorCount="<<colorCount<<endl;
		vector<int> vi_VertexColors;
		g->GetVertexColors(vi_VertexColors);

		//Do (column-)color statistic for each row, i.e., see how many elements in that row has color 0, color 1 ...
		int** colorStatistic = new int*[rowCount];	//color statistic for each row. For example, colorStatistic[0] is color statistic for row 0
													//If row 0 has 5 columns with color 3 => colorStatistic[0][3] = 5;
		//Allocate memory for colorStatistic[rowCount][colorCount] and initilize the matrix
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			colorStatistic[i] = new int[colorCount];
			for(unsigned int j=0; j < (unsigned int)colorCount; j++) colorStatistic[i][j] = 0;
		}

		//populate colorStatistic
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			int numOfNonZeros = uip2_HessianSparsityPattern[i][0];
			for(unsigned int j=1; j <= (unsigned int)numOfNonZeros; j++) {
				//non-zero in the Hessian: [i][uip2_HessianSparsityPattern[i][j]]
				//color of that column: vi_VertexColors[uip2_HessianSparsityPattern[i][j]]
				colorStatistic[i][vi_VertexColors[uip2_HessianSparsityPattern[i][j]]]++;
			}
		}

		//Now, go to the main part, recover the values of non-zero entries in the Hessian
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			unsigned int numOfNonZeros = uip2_HessianSparsityPattern[i][0];
			for(unsigned int j=1; j <= numOfNonZeros; j++) {
				if(uip2_HessianSparsityPattern[i][j]<i) continue;

				if(i == uip2_HessianSparsityPattern[i][j]) { // the non-zero is in the diagonal of the matrix
					HessianValue.push_back(dp2_CompressedMatrix[i][vi_VertexColors[i]]);
				}
				else {// i != uip2_HessianSparsityPattern[i][j] // the non-zero is NOT in the diagonal of the matrix
					if(colorStatistic[i][vi_VertexColors[uip2_HessianSparsityPattern[i][j]]]==1) {
						HessianValue.push_back(dp2_CompressedMatrix[i][vi_VertexColors[uip2_HessianSparsityPattern[i][j]]]);
					}
					else {
						HessianValue.push_back(dp2_CompressedMatrix[uip2_HessianSparsityPattern[i][j]][vi_VertexColors[i]]);
					}
				}
				RowIndex.push_back(i);
				ColumnIndex.push_back(uip2_HessianSparsityPattern[i][j]);
			}
		}

		free_2DMatrix(colorStatistic, rowCount);
		colorStatistic = NULL;

		return (RowIndex.size());
	}

	int HessianRecovery::DirectRecover_CoordinateFormat_usermem(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_HessianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		vector<unsigned int> RowIndex;
		vector<unsigned int> ColumnIndex;
		vector<double> HessianValue;

//		int returnValue = DirectRecover_CoordinateFormat_vectors_OMP(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, RowIndex, ColumnIndex, HessianValue);

		int returnValue = DirectRecover_CoordinateFormat_vectors(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, RowIndex, ColumnIndex, HessianValue);

		unsigned int numOfNonZeros = RowIndex.size();

//		#pragma omp parallel for default(none) schedule(static) shared(numOfNonZeros, ip2_RowIndex, ip2_ColumnIndex, dp2_HessianValue, RowIndex, ColumnIndex, HessianValue)
		for(size_t i=0; i < numOfNonZeros; i++) {
			(*ip2_RowIndex)[i] = RowIndex[i];
			(*ip2_ColumnIndex)[i] = ColumnIndex[i];
			(*dp2_HessianValue)[i] = HessianValue[i];
		}

		return (returnValue);
	}
/*
	int HessianRecovery::DirectRecover_CoordinateFormat_usermem_serial(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_HessianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		vector<unsigned int> RowIndex;
		vector<unsigned int> ColumnIndex;
		vector<double> HessianValue;

		int returnValue = DirectRecover_CoordinateFormat_vectors(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, RowIndex, ColumnIndex, HessianValue);

		unsigned int numOfNonZeros = RowIndex.size();

		for(int i=0; i < numOfNonZeros; i++) {
			(*ip2_RowIndex)[i] = RowIndex[i];
			(*ip2_ColumnIndex)[i] = ColumnIndex[i];
			(*dp2_HessianValue)[i] = HessianValue[i];
		}

		return (returnValue);
	}
*/
/*
	int HessianRecovery::DirectRecover_CoordinateFormat_unmanaged_OMP(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_HessianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		vector<unsigned int> RowIndex;
		vector<unsigned int> ColumnIndex;
		vector<double> HessianValue;

		int returnValue = DirectRecover_CoordinateFormat_vectors_OMP(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, RowIndex, ColumnIndex, HessianValue);

		unsigned int numOfNonZeros = RowIndex.size();
		#pragma omp sections
		{
		  #pragma omp section
		  {
		    (*ip2_RowIndex) = (unsigned int*) malloc(numOfNonZeros * sizeof(unsigned int));
		  }
		  #pragma omp section
		  {
		    (*ip2_ColumnIndex) = (unsigned int*) malloc(numOfNonZeros * sizeof(unsigned int));
		  }
		  #pragma omp section
		  {
		    (*dp2_HessianValue) = (double*) malloc(numOfNonZeros * sizeof(double)); //allocate memory for *dp2_HessianValue.
		  }
		}

		#pragma omp parallel for default(none) schedule(static) shared(numOfNonZeros, ip2_RowIndex, ip2_ColumnIndex, dp2_HessianValue, RowIndex, ColumnIndex, HessianValue)
		for(int i=0; i < numOfNonZeros; i++) {
			(*ip2_RowIndex)[i] = RowIndex[i];
			(*ip2_ColumnIndex)[i] = ColumnIndex[i];
			(*dp2_HessianValue)[i] = HessianValue[i];
		}

		return (returnValue);
	}
*/
	int HessianRecovery::DirectRecover_CoordinateFormat_unmanaged(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_HessianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		vector<unsigned int> RowIndex;
		vector<unsigned int> ColumnIndex;
		vector<double> HessianValue;

		int returnValue = DirectRecover_CoordinateFormat_vectors(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, RowIndex, ColumnIndex, HessianValue);

		unsigned int numOfNonZeros = RowIndex.size();
		(*ip2_RowIndex) = (unsigned int*) malloc(numOfNonZeros * sizeof(unsigned int));
		(*ip2_ColumnIndex) = (unsigned int*) malloc(numOfNonZeros * sizeof(unsigned int));
		(*dp2_HessianValue) = (double*) malloc(numOfNonZeros * sizeof(double)); //allocate memory for *dp2_HessianValue.

		for(size_t i=0; i < numOfNonZeros; i++) {
			(*ip2_RowIndex)[i] = RowIndex[i];
			(*ip2_ColumnIndex)[i] = ColumnIndex[i];
			(*dp2_HessianValue)[i] = HessianValue[i];
		}

		return (returnValue);
	}
/*
	int HessianRecovery::DirectRecover_CoordinateFormat_OMP(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_HessianValue) {
		int numOfNonZeros = DirectRecover_CoordinateFormat_unmanaged_OMP(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, ip2_RowIndex,ip2_ColumnIndex, dp2_HessianValue);

		if(CF_available) reset();

		CF_available = true;
		i_CF_rowCount = g->GetVertexCount();
		ip_CF_RowIndex = *ip2_RowIndex;
		ip_CF_ColumnIndex = *ip2_ColumnIndex;
		dp_CF_Value = *dp2_HessianValue;

		return (numOfNonZeros);
	}
*/
	int HessianRecovery::DirectRecover_CoordinateFormat(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_HessianValue) {
		int numOfNonZeros = DirectRecover_CoordinateFormat_unmanaged(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, ip2_RowIndex,ip2_ColumnIndex, dp2_HessianValue);

		if(CF_available) reset();

		CF_available = true;
		i_CF_rowCount = g->GetVertexCount();
		ip_CF_RowIndex = *ip2_RowIndex;
		ip_CF_ColumnIndex = *ip2_ColumnIndex;
		dp_CF_Value = *dp2_HessianValue;

		return (numOfNonZeros);
	}

	int HessianRecovery::IndirectRecover_RowCompressedFormat_usermem(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, double*** dp3_HessianValue) {
		if (g->GetVertexColorCount()==1){
			return DirectRecover_RowCompressedFormat_usermem(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, dp3_HessianValue);
		}

		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int i=0,j=0;
		int i_VertexCount = _UNKNOWN;
		int i_EdgeID, i_SetID;
		vector<int> vi_Sets;
		map< int, vector<int> > mivi_VertexSets;

		vector<int> vi_Vertices;
		g->GetVertices(vi_Vertices);

		vector<int> vi_Edges;
		g->GetEdges(vi_Edges);

		vector<int> vi_VertexColors;
		g->GetVertexColors(vi_VertexColors);

		map< int, map< int, int> > mimi2_VertexEdgeMap;
		g->GetVertexEdgeMap(mimi2_VertexEdgeMap);

		DisjointSets ds_DisjointSets;
		g->GetDisjointSets(ds_DisjointSets);

		//populate vi_Sets & mivi_VertexSets
		vi_Sets.clear();
		mivi_VertexSets.clear();

		i_VertexCount = g->GetVertexCount();

		for(i=0; i<i_VertexCount; i++) // for each vertex A (indexed by i)
		{
		for(j=vi_Vertices[i]; j<vi_Vertices[STEP_UP(i)]; j++) // for each of the vertex B that connect to A
			{
				if(i < vi_Edges[j]) // if the index of A (i) is less than the index of B (vi_Edges[j])
										//basicly each edge is represented by (vertex with smaller ID, vertex with larger ID). This way, we don't insert a specific edge twice
				{
					i_EdgeID = mimi2_VertexEdgeMap[i][vi_Edges[j]];

					i_SetID = ds_DisjointSets.FindAndCompress(i_EdgeID);

					if(i_SetID == i_EdgeID) // that edge is the root of the set => create new set
					{
						vi_Sets.push_back(i_SetID);
					}

					mivi_VertexSets[i_SetID].push_back(i);
					mivi_VertexSets[i_SetID].push_back(vi_Edges[j]);
				}
			}
		}

		int i_MaximumVertexDegree;

		int i_HighestInducedVertexDegree;

		int i_LeafVertex, i_ParentVertex, i_PresentVertex;

		int i_VertexDegree;

		int i_SetCount, i_SetSize;
		//i_SetCount = vi_Sets.size();
		//i_SetSize: size (number of edges?) in a bicolored tree

		double d_Value;

		vector<int> vi_EvaluatedDiagonals;

		vector<int> vi_InducedVertexDegrees;

		vector<double> vd_IncludedVertices;

		vector< vector<int> > v2i_VertexAdjacency;

		vector< vector<double> > v2d_NonzeroAdjacency;

		vector< list<int> > vli_GroupedInducedVertexDegrees;

		vector< list<int>::iterator > vlit_VertexLocations;

		i_MaximumVertexDegree = g->GetMaximumVertexDegree();

	#if DEBUG == 5103

		cout<<endl;
		cout<<"DEBUG 5103 | Hessian Evaluation | Bicolored Sets"<<endl;
		cout<<endl;

		i_SetCount = (signed) vi_Sets.size();

		for(i=0; i<i_SetCount; i++)
		{
			cout<<STEP_UP(vi_Sets[i])<<"\t"<<" : ";

			i_SetSize = (signed) mivi_VertexSets[vi_Sets[i]].size();

			for(j=0; j<i_SetSize; j++)
			{
				if(j == STEP_DOWN(i_SetSize))
				{
				cout<<STEP_UP(mivi_VertexSets[vi_Sets[i]][j])<<" ("<<i_SetSize<<")"<<endl;
				}
				else
				{
				cout<<STEP_UP(mivi_VertexSets[vi_Sets[i]][j])<<", ";
				}
			}
		}

		cout<<endl;
		cout<<"[Set Count = "<<i_SetCount<<"]"<<endl;
		cout<<endl;

	#endif

		//Step 5: from here on
		i_VertexCount = g->GetVertexCount();

		v2i_VertexAdjacency.clear();
		v2i_VertexAdjacency.resize((unsigned) i_VertexCount);

		v2d_NonzeroAdjacency.clear();
		v2d_NonzeroAdjacency.resize((unsigned) i_VertexCount);

		vi_EvaluatedDiagonals.clear();
		vi_EvaluatedDiagonals.resize((unsigned) i_VertexCount, _FALSE);

		vi_InducedVertexDegrees.clear();
		vi_InducedVertexDegrees.resize((unsigned) i_VertexCount, _FALSE);

		vd_IncludedVertices.clear();
		vd_IncludedVertices.resize((unsigned) i_VertexCount, _UNKNOWN);

		i_ParentVertex = _UNKNOWN;

		i_SetCount = (signed) vi_Sets.size();

		for(i=0; i<i_SetCount; i++)
		{
			vli_GroupedInducedVertexDegrees.clear();
			vli_GroupedInducedVertexDegrees.resize((unsigned) STEP_UP(i_MaximumVertexDegree));

			vlit_VertexLocations.clear();
			vlit_VertexLocations.resize((unsigned) i_VertexCount);

			i_HighestInducedVertexDegree = _UNKNOWN;

			i_SetSize = (signed) mivi_VertexSets[vi_Sets[i]].size();

			for(j=0; j<i_SetSize; j++)
			{
				i_PresentVertex = mivi_VertexSets[vi_Sets[i]][j];

				vd_IncludedVertices[i_PresentVertex] = _FALSE;

				if(vi_InducedVertexDegrees[i_PresentVertex] != _FALSE)
				{
					vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_PresentVertex]].erase(vlit_VertexLocations[i_PresentVertex]);
				}

				vi_InducedVertexDegrees[i_PresentVertex]++;

				if(i_HighestInducedVertexDegree < vi_InducedVertexDegrees[i_PresentVertex])
				{
					i_HighestInducedVertexDegree = vi_InducedVertexDegrees[i_PresentVertex];
				}

				vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_PresentVertex]].push_front(i_PresentVertex);

				vlit_VertexLocations[i_PresentVertex] = vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_PresentVertex]].begin();
			}

	#if DEBUG == 5103

			int k;

			list<int>::iterator lit_ListIterator;

			cout<<endl;
			cout<<"DEBUG 5103 | Hessian Evaluation | Induced Vertex Degrees | Set "<<STEP_UP(i)<<endl;
			cout<<endl;

			for(j=0; j<STEP_UP(i_HighestInducedVertexDegree); j++)
			{
				i_SetSize = (signed) vli_GroupedInducedVertexDegrees[j].size();

				if(i_SetSize == _FALSE)
				{
					continue;
				}

				k = _FALSE;

				cout<<"Degree "<<j<<"\t"<<" : ";

				for(lit_ListIterator=vli_GroupedInducedVertexDegrees[j].begin(); lit_ListIterator!=vli_GroupedInducedVertexDegrees[j].end(); lit_ListIterator++)
				{
					if(k == STEP_DOWN(i_SetSize))
					{
						cout<<STEP_UP(*lit_ListIterator)<<"{"<<vd_IncludedVertices[*lit_ListIterator]<<"} ("<<i_SetSize<<")"<<endl;
					}
					else
					{
						cout<<STEP_UP(*lit_ListIterator)<<"{"<<vd_IncludedVertices[*lit_ListIterator]<<"}, ";
					}

					k++;
				}
			}

	#endif

	#if DEBUG == 5103

			cout<<endl;
			cout<<"DEBUG 5103 | Hessian Evaluation | Retrieved Elements"<<"| Set "<<STEP_UP(i)<<endl;
			cout<<endl;

	#endif
//#define DEBUG 5103
			//get the diagonal values
			for (int index = 0; index < i_VertexCount; index++) {
				if(vi_EvaluatedDiagonals[index] == _FALSE)
				{
					d_Value = dp2_CompressedMatrix[index][vi_VertexColors[index]];

	#if DEBUG == 5103

					cout<<"Element["<<STEP_UP(index)<<"]["<<STEP_UP(index)<<"] = "<<d_Value<<endl;

	#endif
					v2i_VertexAdjacency[index].push_back(index);
					v2d_NonzeroAdjacency[index].push_back(d_Value);

					vi_EvaluatedDiagonals[index] = _TRUE;

				}
			}

			for ( ; ; )
			{
				if(vli_GroupedInducedVertexDegrees[_TRUE].empty()) // If there is no leaf left on the color tree
				{
					i_LeafVertex = vli_GroupedInducedVertexDegrees[_FALSE].front();

					vi_InducedVertexDegrees[i_LeafVertex] = _FALSE;

					vd_IncludedVertices[i_LeafVertex] = _UNKNOWN;

					break;
				}

				i_LeafVertex = vli_GroupedInducedVertexDegrees[_TRUE].front();

				vli_GroupedInducedVertexDegrees[_TRUE].pop_front();


				//Find i_ParentVertex
				for(j=vi_Vertices[i_LeafVertex]; j<vi_Vertices[STEP_UP(i_LeafVertex)]; j++)
				{
					if(vd_IncludedVertices[vi_Edges[j]] != _UNKNOWN)
					{
						i_ParentVertex = vi_Edges[j];

						break;
					}
				}

				d_Value = dp2_CompressedMatrix[i_LeafVertex][vi_VertexColors[i_ParentVertex]] - vd_IncludedVertices[i_LeafVertex];

				vd_IncludedVertices[i_ParentVertex] += d_Value;

				vi_InducedVertexDegrees[i_LeafVertex] = _FALSE;
				vd_IncludedVertices[i_LeafVertex] = _UNKNOWN;
				if(vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_ParentVertex]].size()>1) {
					vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_ParentVertex]].erase(vlit_VertexLocations[i_ParentVertex]);
				}
				else {
					vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_ParentVertex]].pop_back();
				}

				vi_InducedVertexDegrees[i_ParentVertex]--;
				vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_ParentVertex]].push_back(i_ParentVertex);

				//Update position of the iterator pointing to i_ParentVertex in "InducedVertexDegrees" structure
				vlit_VertexLocations[i_ParentVertex] = vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_ParentVertex]].end();
				--vlit_VertexLocations[i_ParentVertex];

				v2i_VertexAdjacency[i_LeafVertex].push_back(i_ParentVertex);
				v2d_NonzeroAdjacency[i_LeafVertex].push_back(d_Value);

				v2i_VertexAdjacency[i_ParentVertex].push_back(i_LeafVertex);
				v2d_NonzeroAdjacency[i_ParentVertex].push_back(d_Value);


	#if DEBUG == 5103

				cout<<"Element["<<STEP_UP(i_LeafVertex)<<"]["<<STEP_UP(i_ParentVertex)<<"] = "<<d_Value<<endl;
	#endif

			}
		}


		//allocate memory for *dp3_HessianValue. The dp3_HessianValue and uip2_HessianSparsityPattern matrices should have the same size
		//*dp3_HessianValue = new double*[i_VertexCount];
		//for(unsigned int i=0; i < (unsigned int)i_VertexCount; i++) {
		//	unsigned int numOfNonZeros = uip2_HessianSparsityPattern[i][0];
		//	(*dp3_HessianValue)[i] = new double[numOfNonZeros+1];
		//	(*dp3_HessianValue)[i][0] = numOfNonZeros; //initialize value of the 1st entry
		//	for(unsigned int j=1; j <= numOfNonZeros; j++) (*dp3_HessianValue)[i][j] = 0.; //initialize value of other entries
		//}

		//populate dp3_HessianValue row by row, column by column
		for(i=0; i<i_VertexCount; i++) {
			int NumOfNonzeros = uip2_HessianSparsityPattern[i][0];
			i_VertexDegree = (signed) v2i_VertexAdjacency[i].size();
			for(j=1; j<=NumOfNonzeros; j++) {
				int targetColumnID = uip2_HessianSparsityPattern[i][j];
				for (int k=0; k<i_VertexDegree; k++) {// search through the v2i_VertexAdjacency matrix to find the correct column
					if(targetColumnID == v2i_VertexAdjacency[i][k]) { //found it
						(*dp3_HessianValue)[i][j] = v2d_NonzeroAdjacency[i][k];
						break;
					}
				}
			}
		}


		return (i_VertexCount);
	}

	int HessianRecovery::IndirectRecover_RowCompressedFormat_unmanaged(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, double*** dp3_HessianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetVertexCount();

		//allocate memory for *dp3_HessianValue. The dp3_HessianValue and uip2_HessianSparsityPattern matrices should have the same size
		*dp3_HessianValue = (double**) malloc(rowCount * sizeof(double*));
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			unsigned int numOfNonZeros = uip2_HessianSparsityPattern[i][0];
			(*dp3_HessianValue)[i] = (double*) malloc( (numOfNonZeros+1) * sizeof(double) );
			(*dp3_HessianValue)[i][0] = numOfNonZeros; //initialize value of the 1st entry
			for(unsigned int j=1; j <= numOfNonZeros; j++) (*dp3_HessianValue)[i][j] = 0.; //initialize value of other entries
		}

		return IndirectRecover_RowCompressedFormat_usermem(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, dp3_HessianValue);
	}

	int HessianRecovery::IndirectRecover_RowCompressedFormat(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, double*** dp3_HessianValue) {

		int returnValue = IndirectRecover_RowCompressedFormat_unmanaged( g,  dp2_CompressedMatrix,  uip2_HessianSparsityPattern, dp3_HessianValue);

		if(AF_available) reset();

		AF_available = true;
		i_AF_rowCount = g->GetVertexCount();
		dp2_AF_Value = *dp3_HessianValue;

		return (returnValue);
	}

	int HessianRecovery::IndirectRecover_SparseSolversFormat_usermem(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_HessianValue, unsigned int numOfNonZerosInHessianValue) {
		if (g->GetVertexColorCount()==1){
			return DirectRecover_SparseSolversFormat_usermem(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, ip2_RowIndex,  ip2_ColumnIndex, dp2_HessianValue,numOfNonZerosInHessianValue);
		}

		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		//unsigned int numOfNonZerosInHessianValue = ConvertRowCompressedFormat2SparseSolversFormat_StructureOnly(uip2_HessianSparsityPattern, g->GetVertexCount(), ip2_RowIndex, ip2_ColumnIndex);

		int i_VertexCount = g->GetVertexCount();

		//Making the array indices to start at 0 instead of 1
		for(unsigned int i=0; i <= (unsigned int) i_VertexCount ; i++) {
		  (*ip2_RowIndex)[i]--;
		}
		for(unsigned int i=0; i < numOfNonZerosInHessianValue; i++) {
		  (*ip2_ColumnIndex)[i]--;
		}

		int i=0,j=0;
		int i_EdgeID, i_SetID;
		vector<int> vi_Sets;
		map< int, vector<int> > mivi_VertexSets;

		vector<int> vi_Vertices;
		g->GetVertices(vi_Vertices);

		vector<int> vi_Edges;
		g->GetEdges(vi_Edges);

		vector<int> vi_VertexColors;
		g->GetVertexColors(vi_VertexColors);

		map< int, map< int, int> > mimi2_VertexEdgeMap;
		g->GetVertexEdgeMap(mimi2_VertexEdgeMap);

		DisjointSets ds_DisjointSets;
		g->GetDisjointSets(ds_DisjointSets);

		//populate vi_Sets & mivi_VertexSets
		vi_Sets.clear();
		mivi_VertexSets.clear();


		for(i=0; i<i_VertexCount; i++) // for each vertex A (indexed by i)
		{
			for(j=vi_Vertices[i]; j<vi_Vertices[STEP_UP(i)]; j++) // for each of the vertex B that connect to A
			{
				if(i < vi_Edges[j]) // if the index of A (i) is less than the index of B (vi_Edges[j])
										//basic each edge is represented by (vertex with smaller ID, vertex with larger ID). This way, we don't insert a specific edge twice
				{
					i_EdgeID = mimi2_VertexEdgeMap[i][vi_Edges[j]];

					i_SetID = ds_DisjointSets.FindAndCompress(i_EdgeID);

					if(i_SetID == i_EdgeID) // that edge is the root of the set => create new set
					{
						vi_Sets.push_back(i_SetID);
					}

					mivi_VertexSets[i_SetID].push_back(i);
					mivi_VertexSets[i_SetID].push_back(vi_Edges[j]);
				}
			}
		}

		int i_MaximumVertexDegree;

		int i_HighestInducedVertexDegree;

		int i_LeafVertex, i_ParentVertex, i_PresentVertex;

		int i_VertexDegree;

		int i_SetCount, i_SetSize;

		double d_Value;

		vector<int> vi_EvaluatedDiagonals;

		vector<int> vi_InducedVertexDegrees;

		vector<double> vd_IncludedVertices;

		vector< vector<int> > v2i_VertexAdjacency;

		vector< vector<double> > v2d_NonzeroAdjacency;

		vector< list<int> > vli_GroupedInducedVertexDegrees;

		vector< list<int>::iterator > vlit_VertexLocations;

		i_MaximumVertexDegree = g->GetMaximumVertexDegree();

	#if DEBUG == 5103

		cout<<endl;
		cout<<"DEBUG 5103 | Hessian Evaluation | Bicolored Sets"<<endl;
		cout<<endl;

		i_SetCount = (signed) vi_Sets.size();

		for(i=0; i<i_SetCount; i++)
		{
			cout<<STEP_UP(vi_Sets[i])<<"\t"<<" : ";

			i_SetSize = (signed) mivi_VertexSets[vi_Sets[i]].size();

			for(j=0; j<i_SetSize; j++)
			{
				if(j == STEP_DOWN(i_SetSize))
				{
				cout<<STEP_UP(mivi_VertexSets[vi_Sets[i]][j])<<" ("<<i_SetSize<<")"<<endl;
				}
				else
				{
				cout<<STEP_UP(mivi_VertexSets[vi_Sets[i]][j])<<", ";
				}
			}
		}

		cout<<endl;
		cout<<"[Set Count = "<<i_SetCount<<"]"<<endl;
		cout<<endl;

	#endif

		//Step 5: from here on
		i_VertexCount = g->GetVertexCount();

		v2i_VertexAdjacency.clear();
		v2i_VertexAdjacency.resize((unsigned) i_VertexCount);

		v2d_NonzeroAdjacency.clear();
		v2d_NonzeroAdjacency.resize((unsigned) i_VertexCount);

		vi_EvaluatedDiagonals.clear();
		vi_EvaluatedDiagonals.resize((unsigned) i_VertexCount, _FALSE);

		vi_InducedVertexDegrees.clear();
		vi_InducedVertexDegrees.resize((unsigned) i_VertexCount, _FALSE);

		vd_IncludedVertices.clear();
		vd_IncludedVertices.resize((unsigned) i_VertexCount, _UNKNOWN);

		i_ParentVertex = _UNKNOWN;

		i_SetCount = (signed) vi_Sets.size();

		for(i=0; i<i_SetCount; i++)
		{
			vli_GroupedInducedVertexDegrees.clear();
			vli_GroupedInducedVertexDegrees.resize((unsigned) STEP_UP(i_MaximumVertexDegree));

			vlit_VertexLocations.clear();
			vlit_VertexLocations.resize((unsigned) i_VertexCount);

			i_HighestInducedVertexDegree = _UNKNOWN;

			i_SetSize = (signed) mivi_VertexSets[vi_Sets[i]].size();

			for(j=0; j<i_SetSize; j++)
			{
				i_PresentVertex = mivi_VertexSets[vi_Sets[i]][j];

				vd_IncludedVertices[i_PresentVertex] = _FALSE;

				if(vi_InducedVertexDegrees[i_PresentVertex] != _FALSE)
				{
					vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_PresentVertex]].erase(vlit_VertexLocations[i_PresentVertex]);
				}

				vi_InducedVertexDegrees[i_PresentVertex]++;

				if(i_HighestInducedVertexDegree < vi_InducedVertexDegrees[i_PresentVertex])
				{
					i_HighestInducedVertexDegree = vi_InducedVertexDegrees[i_PresentVertex];
				}

				vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_PresentVertex]].push_front(i_PresentVertex);

				vlit_VertexLocations[i_PresentVertex] = vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_PresentVertex]].begin();
			}

	#if DEBUG == 5103

			int k;

			list<int>::iterator lit_ListIterator;

			cout<<endl;
			cout<<"DEBUG 5103 | Hessian Evaluation | Induced Vertex Degrees | Set "<<STEP_UP(i)<<endl;
			cout<<endl;

			for(j=0; j<STEP_UP(i_HighestInducedVertexDegree); j++)
			{
				i_SetSize = (signed) vli_GroupedInducedVertexDegrees[j].size();

				if(i_SetSize == _FALSE)
				{
					continue;
				}

				k = _FALSE;

				cout<<"Degree "<<j<<"\t"<<" : ";

				for(lit_ListIterator=vli_GroupedInducedVertexDegrees[j].begin(); lit_ListIterator!=vli_GroupedInducedVertexDegrees[j].end(); lit_ListIterator++)
				{
					if(k == STEP_DOWN(i_SetSize))
					{
						cout<<STEP_UP(*lit_ListIterator)<<" ("<<i_SetSize<<")"<<endl;
					}
					else
					{
						cout<<STEP_UP(*lit_ListIterator)<<", ";
					}

					k++;
				}
			}

	#endif

	#if DEBUG == 5103

			cout<<endl;
			cout<<"DEBUG 5103 | Hessian Evaluation | Retrieved Elements"<<"| Set "<<STEP_UP(i)<<endl;
			cout<<endl;

	#endif
//#define DEBUG 5103
			//get the diagonal values
			for (int index = 0; index < i_VertexCount; index++) {
				if(vi_EvaluatedDiagonals[index] == _FALSE)
				{
					d_Value = dp2_CompressedMatrix[index][vi_VertexColors[index]];

	#if DEBUG == 5103

					cout<<"Element["<<STEP_UP(index)<<"]["<<STEP_UP(index)<<"] = "<<d_Value<<endl;

	#endif
					v2i_VertexAdjacency[index].push_back(index);
					v2d_NonzeroAdjacency[index].push_back(d_Value);

					vi_EvaluatedDiagonals[index] = _TRUE;

				}
			}

			for ( ; ; )
			{
				if(vli_GroupedInducedVertexDegrees[_TRUE].empty()) // If there is no leaf left on the color tree
				{
					i_LeafVertex = vli_GroupedInducedVertexDegrees[_FALSE].front();

					vi_InducedVertexDegrees[i_LeafVertex] = _FALSE;

					vd_IncludedVertices[i_LeafVertex] = _UNKNOWN;

					break;
				}

				i_LeafVertex = vli_GroupedInducedVertexDegrees[_TRUE].front();

				vli_GroupedInducedVertexDegrees[_TRUE].pop_front();

				//Find i_ParentVertex
				for(j=vi_Vertices[i_LeafVertex]; j<vi_Vertices[STEP_UP(i_LeafVertex)]; j++)
				{
					if(vd_IncludedVertices[vi_Edges[j]] != _UNKNOWN)
					{
						i_ParentVertex = vi_Edges[j];

						break;
					}
				}

				d_Value = dp2_CompressedMatrix[i_LeafVertex][vi_VertexColors[i_ParentVertex]] - vd_IncludedVertices[i_LeafVertex];

				vd_IncludedVertices[i_ParentVertex] += d_Value;

				vi_InducedVertexDegrees[i_LeafVertex] = _FALSE;
				vd_IncludedVertices[i_LeafVertex] = _UNKNOWN;
				if(vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_ParentVertex]].size()>1) {
					vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_ParentVertex]].erase(vlit_VertexLocations[i_ParentVertex]);
				}
				else {
					vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_ParentVertex]].pop_back();
				}

				vi_InducedVertexDegrees[i_ParentVertex]--;
				vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_ParentVertex]].push_back(i_ParentVertex);

				//Update position of the iterator pointing to i_ParentVertex in "InducedVertexDegrees" structure
				vlit_VertexLocations[i_ParentVertex] = vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_ParentVertex]].end();
				--vlit_VertexLocations[i_ParentVertex];

				v2i_VertexAdjacency[i_LeafVertex].push_back(i_ParentVertex);
				v2d_NonzeroAdjacency[i_LeafVertex].push_back(d_Value);

				v2i_VertexAdjacency[i_ParentVertex].push_back(i_LeafVertex);
				v2d_NonzeroAdjacency[i_ParentVertex].push_back(d_Value);

	#if DEBUG == 5103

				cout<<"Element["<<STEP_UP(i_LeafVertex)<<"]["<<STEP_UP(i_ParentVertex)<<"] = "<<d_Value<<endl;
	#endif

			}
		}



		//cout<<"allocate memory for *dp2_HessianValue rowCount="<<rowCount<<endl;
		//printf("i=%d\t numOfNonZerosInHessianValue=%d \n", i, numOfNonZerosInHessianValue);
		//(*dp2_HessianValue) = new double[numOfNonZerosInHessianValue]; //allocate memory for *dp2_JacobianValue.
		//for(unsigned int i=0; i < numOfNonZerosInHessianValue; i++) (*dp2_HessianValue)[i] = 0.; //initialize value of other entries

		//populate dp2_HessianValue row by row, column by column
		for(i=0; i<i_VertexCount; i++) {
			int NumOfNonzeros = uip2_HessianSparsityPattern[i][0];
			int offset = 0;
			i_VertexDegree = (signed) v2i_VertexAdjacency[i].size();
			for(j=1; j<=NumOfNonzeros; j++) {
				if( (unsigned)i > uip2_HessianSparsityPattern[i][j] ) {
				  offset++;
				  continue;
				}
				int targetColumnID = uip2_HessianSparsityPattern[i][j];
				for (int k=0; k<i_VertexDegree; k++) {// search through the v2i_VertexAdjacency matrix to find the correct column
					if(targetColumnID == v2i_VertexAdjacency[i][k]) { //found it
						(*dp2_HessianValue)[(*ip2_RowIndex)[i] + j - offset - 1] = v2d_NonzeroAdjacency[i][k];
						break;
					}
				}
			}
		}



		//Making the array indices to start at 1 instead of 0 to conform with theIntel MKL sparse storage scheme for the direct sparse solvers
		for(unsigned int i=0; i <= (unsigned int) i_VertexCount ; i++) {
		  (*ip2_RowIndex)[i]++;
		}
		for(unsigned int i=0; i < numOfNonZerosInHessianValue; i++) {
		  (*ip2_ColumnIndex)[i]++;
		}

		return (i_VertexCount);
	}

	int HessianRecovery::IndirectRecover_SparseSolversFormat_unmanaged(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_HessianValue, unsigned int numOfNonZerosInHessianValue) {

		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetVertexCount();

		if (numOfNonZerosInHessianValue < 1) {
		  numOfNonZerosInHessianValue = ConvertRowCompressedFormat2SparseSolversFormat_StructureOnly(uip2_HessianSparsityPattern, rowCount, ip2_RowIndex, ip2_ColumnIndex);

		  //Making the array indices to start at 1 instead of 0 to conform with the Intel MKL sparse storage scheme for the direct sparse solvers
		  for(unsigned int i=0; i <= (unsigned int) rowCount ; i++) {
		    (*ip2_RowIndex)[i]++;
		  }
		  for(unsigned int i=0; i < numOfNonZerosInHessianValue; i++) {
		    (*ip2_ColumnIndex)[i]++;
		  }
		}

		//cout<<"allocate memory for *dp2_HessianValue rowCount="<<rowCount<<endl;
		//printf("i=%d\t numOfNonZerosInHessianValue=%d \n", i, numOfNonZerosInHessianValue);
		(*dp2_HessianValue) = (double*) malloc(numOfNonZerosInHessianValue * sizeof(double)); //allocate memory for *dp2_JacobianValue.
		for(unsigned int i=0; i < numOfNonZerosInHessianValue; i++) (*dp2_HessianValue)[i] = 0.; //initialize value of other entries

		int returnValue = IndirectRecover_SparseSolversFormat_usermem(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, ip2_RowIndex, ip2_ColumnIndex, dp2_HessianValue, numOfNonZerosInHessianValue);

		return returnValue;
	}

	int HessianRecovery::IndirectRecover_SparseSolversFormat(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_HessianValue) {

		int returnValue = IndirectRecover_SparseSolversFormat_unmanaged( g,  dp2_CompressedMatrix,  uip2_HessianSparsityPattern, ip2_RowIndex,  ip2_ColumnIndex,  dp2_HessianValue);

		if(SSF_available) {
			//cout<<"SSF_available="<<SSF_available<<endl; Pause();
			reset();
		}

		SSF_available = true;
		i_SSF_rowCount = g->GetVertexCount();
		ip_SSF_RowIndex = *ip2_RowIndex;
		ip_SSF_ColumnIndex = *ip2_ColumnIndex;
		dp_SSF_Value = *dp2_HessianValue;

		return (returnValue);
	}

	int HessianRecovery::IndirectRecover_CoordinateFormat_unmanaged(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue) {
#ifdef	_COLPACK_CHECKPOINT_
		cout<<"IN 1 HessianRecovery::IndirectRecover_CoordinateFormat_unmanaged()"<<endl;
		string s_postfix = "-IndirectRecover_CoordinateFormat_vectors";
cout<<"*WriteMatrixMarket_ADOLCInput("<<s_postfix<<", 1, uip2_HessianSparsityPattern, "<< g->GetVertexCount() <<", " << g->GetVertexCount() <<", dp2_CompressedMatrix, " << g->GetVertexCount() <<", "  << g->GetVertexColorCount() <<endl;
		WriteMatrixMarket_ADOLCInput(s_postfix, 1, uip2_HessianSparsityPattern, g->GetVertexCount(), g->GetVertexCount() , dp2_CompressedMatrix, g->GetVertexCount(), g->GetVertexColorCount() );
#endif
		if (g->GetVertexColorCount()==1){
			return DirectRecover_CoordinateFormat_unmanaged(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, uip2_RowIndex,  uip2_ColumnIndex, dp2_HessianValue);
		}
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		vector<unsigned int> RowIndex;
		vector<unsigned int> ColumnIndex;
		vector<double> HessianValue;

		int returnValue = IndirectRecover_CoordinateFormat_vectors(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, RowIndex, ColumnIndex, HessianValue);

		unsigned int numOfNonZeros = returnValue;
		(*uip2_RowIndex) = (unsigned int*) malloc(numOfNonZeros * sizeof(unsigned int));
		(*uip2_ColumnIndex) = (unsigned int*) malloc(numOfNonZeros * sizeof(unsigned int));
		(*dp2_HessianValue) = (double*) malloc(numOfNonZeros * sizeof(double)); //allocate memory for *dp2_HessianValue.

		for(size_t i=0; i < numOfNonZeros; i++) {
			(*uip2_RowIndex)[i] = RowIndex[i];
			(*uip2_ColumnIndex)[i] = ColumnIndex[i];
			(*dp2_HessianValue)[i] = HessianValue[i];
		}

#ifdef	_COLPACK_CHECKPOINT_
		cout<<"IN 2 HessianRecovery::IndirectRecover_CoordinateFormat_unmanaged()"<<endl;
		unsigned int*** dp3_Pattern = (unsigned int***) malloc( sizeof(unsigned int**) );
		double*** dp3_Values = (double***) malloc( sizeof(double**) );
		ConvertCoordinateFormat2RowCompressedFormat((*uip2_RowIndex), (*uip2_ColumnIndex), (*dp2_HessianValue), g->GetVertexCount(), numOfNonZeros, dp3_Pattern, dp3_Values );

		s_postfix = "-IndirectRecover_CoordinateFormat_vectors";
cout<<"*WriteMatrixMarket_ADOLCInput("<<s_postfix<<", 2, uip2_HessianSparsityPattern, "<< g->GetVertexCount() <<", " << g->GetVertexCount() <<", dp2_CompressedMatrix, " << g->GetVertexCount() <<", "  << g->GetVertexColorCount()<<", dp3_Values" <<endl;
		WriteMatrixMarket_ADOLCInput(s_postfix, 2, uip2_HessianSparsityPattern, g->GetVertexCount(), g->GetVertexCount() , dp2_CompressedMatrix, g->GetVertexCount(), g->GetVertexColorCount(), dp3_Values );

		//Deallocate dp3_Pattern & dp3_Values
		freeMatrix(dp3_Pattern, g->GetVertexCount());
		freeMatrix(dp3_Values, g->GetVertexCount());
#endif
		return (returnValue);
	}

		// !!! Note: the speed of this function could be improved by reserve the vectors size for (RowIndex, ColumnIndex, HessianValue) ahead of time
	int HessianRecovery::IndirectRecover_CoordinateFormat_vectors(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, vector<unsigned int> &RowIndex, vector<unsigned int> &ColumnIndex, vector<double> &HessianValue) {
		int i=0,j=0;
		int i_VertexCount = _UNKNOWN;
		int i_EdgeID, i_SetID;
		vector<int> vi_Sets;
		map< int, vector<int> > mivi_VertexSets;
		vector<int> vi_Vertices;
		g->GetVertices(vi_Vertices);
		vector<int> vi_Edges;
		g->GetEdges(vi_Edges);
		vector<int> vi_VertexColors;
		g->GetVertexColors(vi_VertexColors);
		map< int, map< int, int> > mimi2_VertexEdgeMap;
		g->GetVertexEdgeMap(mimi2_VertexEdgeMap);
		DisjointSets ds_DisjointSets;
		g->GetDisjointSets(ds_DisjointSets);
		//populate vi_Sets & mivi_VertexSets
		vi_Sets.clear();
		mivi_VertexSets.clear();

		i_VertexCount = g->GetVertexCount();

		for(i=0; i<i_VertexCount; i++) // for each vertex A (indexed by i)
		{
			for(j=vi_Vertices[i]; j<vi_Vertices[STEP_UP(i)]; j++) // for each of the vertex B that connect to A
			{
				if(i < vi_Edges[j]) // if the index of A (i) is less than the index of B (vi_Edges[j])
										//basically each edge is represented by (vertex with smaller ID, vertex with larger ID). This way, we don't insert a specific edge twice
				{
					i_EdgeID = mimi2_VertexEdgeMap[i][vi_Edges[j]];

					i_SetID = ds_DisjointSets.FindAndCompress(i_EdgeID);

					if(i_SetID == i_EdgeID) // that edge is the root of the set => create new set
					{
						vi_Sets.push_back(i_SetID);
					}

					mivi_VertexSets[i_SetID].push_back(i);
					mivi_VertexSets[i_SetID].push_back(vi_Edges[j]);
				}
			}
		}

		int i_MaximumVertexDegree;

		int i_HighestInducedVertexDegree;

		int i_LeafVertex, i_ParentVertex, i_PresentVertex;

		int i_VertexDegree;

		int i_SetCount, i_SetSize;

		double d_Value;

		vector<int> vi_EvaluatedDiagonals;

		vector<int> vi_InducedVertexDegrees;

		vector<double> vd_IncludedVertices;
		vector<bool> vb_IncludedVertices;

		vector< vector<int> > v2i_VertexAdjacency;

		vector< vector<double> > v2d_NonzeroAdjacency;

		vector< list<int> > vli_GroupedInducedVertexDegrees;

		vector< list<int>::iterator > vlit_VertexLocations;

		i_MaximumVertexDegree = g->GetMaximumVertexDegree();
	#if DEBUG == 5103

		cout<<endl;
		cout<<"DEBUG 5103 | Hessian Evaluation | Bicolored Sets"<<endl;
		cout<<endl;

		i_SetCount = (signed) vi_Sets.size();

		for(i=0; i<i_SetCount; i++)
		{
			cout<<STEP_UP(vi_Sets[i])<<"\t"<<" : ";

			i_SetSize = (signed) mivi_VertexSets[vi_Sets[i]].size();

			for(j=0; j<i_SetSize; j++)
			{
				if(j == STEP_DOWN(i_SetSize))
				{
				cout<<STEP_UP(mivi_VertexSets[vi_Sets[i]][j])<<" ("<<i_SetSize<<")"<<endl;
				}
				else
				{
				cout<<STEP_UP(mivi_VertexSets[vi_Sets[i]][j])<<", ";
				}
			}
		}

		cout<<endl;
		cout<<"[Set Count = "<<i_SetCount<<"]"<<endl;
		cout<<endl;

	#endif

		//Step 5: from here on
		i_VertexCount = g->GetVertexCount();

		v2i_VertexAdjacency.clear();
		v2i_VertexAdjacency.resize((unsigned) i_VertexCount);

		v2d_NonzeroAdjacency.clear();
		v2d_NonzeroAdjacency.resize((unsigned) i_VertexCount);

		vi_EvaluatedDiagonals.clear();
		vi_EvaluatedDiagonals.resize((unsigned) i_VertexCount, _FALSE);

		vi_InducedVertexDegrees.clear();
		vi_InducedVertexDegrees.resize((unsigned) i_VertexCount, _FALSE);

		vd_IncludedVertices.clear();
		vd_IncludedVertices.resize((unsigned) i_VertexCount, 0.);
		vb_IncludedVertices.clear();
		vb_IncludedVertices.resize((unsigned) i_VertexCount, false);

		i_ParentVertex = _UNKNOWN;

		i_SetCount = (signed) vi_Sets.size();

		for(i=0; i<i_SetCount; i++)
		{
			vli_GroupedInducedVertexDegrees.clear();
			vli_GroupedInducedVertexDegrees.resize((unsigned) STEP_UP(i_MaximumVertexDegree));

			vlit_VertexLocations.clear();
			vlit_VertexLocations.resize((unsigned) i_VertexCount);

			i_HighestInducedVertexDegree = _UNKNOWN;

			i_SetSize = (signed) mivi_VertexSets[vi_Sets[i]].size();

			for(j=0; j<i_SetSize; j++)
			{
				i_PresentVertex = mivi_VertexSets[vi_Sets[i]][j];

				vb_IncludedVertices[i_PresentVertex] = true;
				vd_IncludedVertices[i_PresentVertex] = 0;

				if(vi_InducedVertexDegrees[i_PresentVertex] != _FALSE)
				{
					vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_PresentVertex]].erase(vlit_VertexLocations[i_PresentVertex]);
				}

				vi_InducedVertexDegrees[i_PresentVertex]++;

				if(i_HighestInducedVertexDegree < vi_InducedVertexDegrees[i_PresentVertex])
				{
					i_HighestInducedVertexDegree = vi_InducedVertexDegrees[i_PresentVertex];
				}
				vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_PresentVertex]].push_front(i_PresentVertex);

				vlit_VertexLocations[i_PresentVertex] = vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_PresentVertex]].begin();
			}

	#if DEBUG == 5103

			int k;

			list<int>::iterator lit_ListIterator;

			cout<<endl;
			cout<<"DEBUG 5103 | Hessian Evaluation | Induced Vertex Degrees | Set "<<STEP_UP(i)<<endl;
			cout<<endl;

			for(j=0; j<STEP_UP(i_HighestInducedVertexDegree); j++)
			{
				i_SetSize = (signed) vli_GroupedInducedVertexDegrees[j].size();

				if(i_SetSize == _FALSE)
				{
					continue;
				}

				k = _FALSE;

				cout<<"Degree "<<j<<"\t"<<" : ";

				for(lit_ListIterator=vli_GroupedInducedVertexDegrees[j].begin(); lit_ListIterator!=vli_GroupedInducedVertexDegrees[j].end(); lit_ListIterator++)
				{
					if(k == STEP_DOWN(i_SetSize))
					{
						cout<<STEP_UP(*lit_ListIterator)<<"{"<<vd_IncludedVertices[*lit_ListIterator]<<"} ("<<i_SetSize<<")"<<endl;
					}
					else
					{
						cout<<STEP_UP(*lit_ListIterator)<<"{"<<vd_IncludedVertices[*lit_ListIterator]<<"}, ";
					}

					k++;
				}
			}

	#endif

	#if DEBUG == 5103

			cout<<endl;
			cout<<"DEBUG 5103 | Hessian Evaluation | Retrieved Elements"<<"| Set "<<STEP_UP(i)<<endl;
			cout<<endl;

	#endif
			//get the diagonal values
			for (int index = 0; index < i_VertexCount; index++) {
				if(vi_EvaluatedDiagonals[index] == _FALSE)
				{
					d_Value = dp2_CompressedMatrix[index][vi_VertexColors[index]];

	#if DEBUG == 5103

					cout<<"Element["<<STEP_UP(index)<<"]["<<STEP_UP(index)<<"] = "<<d_Value<<endl;

	#endif
					v2i_VertexAdjacency[index].push_back(index);
					v2d_NonzeroAdjacency[index].push_back(d_Value);

					vi_EvaluatedDiagonals[index] = _TRUE;

				}
			}

			for ( ; ; )
			{
				if(vli_GroupedInducedVertexDegrees[_TRUE].empty()) // If there is no leaf left on the color tree
				{
					i_LeafVertex = vli_GroupedInducedVertexDegrees[_FALSE].front();

					vi_InducedVertexDegrees[i_LeafVertex] = _FALSE;

					vb_IncludedVertices[i_LeafVertex] = false;

					break;
				}

				i_LeafVertex = vli_GroupedInducedVertexDegrees[_TRUE].front();

				vli_GroupedInducedVertexDegrees[_TRUE].pop_front();

				//Find i_ParentVertex
				for(j=vi_Vertices[i_LeafVertex]; j<vi_Vertices[STEP_UP(i_LeafVertex)]; j++)
				{
					if(vb_IncludedVertices[vi_Edges[j]])
					{
						i_ParentVertex = vi_Edges[j];

						break;
					}
				}

				d_Value = dp2_CompressedMatrix[i_LeafVertex][vi_VertexColors[i_ParentVertex]] - vd_IncludedVertices[i_LeafVertex];

				vd_IncludedVertices[i_ParentVertex] += d_Value;

				vi_InducedVertexDegrees[i_LeafVertex] = _FALSE;
				vb_IncludedVertices[i_LeafVertex] = false;
				if(vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_ParentVertex]].size()>1) {
					vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_ParentVertex]].erase(vlit_VertexLocations[i_ParentVertex]);
				}
				else {
					vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_ParentVertex]].pop_back();
				}

				vi_InducedVertexDegrees[i_ParentVertex]--;
				vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_ParentVertex]].push_back(i_ParentVertex);

				//Update position of the iterator pointing to i_ParentVertex in "InducedVertexDegrees" structure
				vlit_VertexLocations[i_ParentVertex] = vli_GroupedInducedVertexDegrees[vi_InducedVertexDegrees[i_ParentVertex]].end();
				--vlit_VertexLocations[i_ParentVertex];

				v2i_VertexAdjacency[i_LeafVertex].push_back(i_ParentVertex);
				v2d_NonzeroAdjacency[i_LeafVertex].push_back(d_Value);

				v2i_VertexAdjacency[i_ParentVertex].push_back(i_LeafVertex);
				v2d_NonzeroAdjacency[i_ParentVertex].push_back(d_Value);


	#if DEBUG == 5103

				cout<<"Element["<<STEP_UP(i_LeafVertex)<<"]["<<STEP_UP(i_ParentVertex)<<"] = "<<d_Value<<endl;
	#endif

			}
		}

		//populate dp3_HessianValue row by row, column by column
		for(i=0; i<i_VertexCount; i++) {
			int NumOfNonzeros = uip2_HessianSparsityPattern[i][0];
			i_VertexDegree = (signed) v2i_VertexAdjacency[i].size();
			for(j=1; j<=NumOfNonzeros; j++) {
				int targetColumnID = uip2_HessianSparsityPattern[i][j];
				if(targetColumnID<i) continue;
				for (int k=0; k<i_VertexDegree; k++) {// search through the v2i_VertexAdjacency matrix to find the correct column
					if(targetColumnID == v2i_VertexAdjacency[i][k]) { //found it
						HessianValue.push_back(v2d_NonzeroAdjacency[i][k]);
						break;
					}
				}
				RowIndex.push_back(i);
				ColumnIndex.push_back(uip2_HessianSparsityPattern[i][j]);
			}
		}

		return ( RowIndex.size() );
	}

	int HessianRecovery::IndirectRecover_CoordinateFormat_usermem(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_HessianValue) {
		if (g->GetVertexColorCount()==1){
			return DirectRecover_CoordinateFormat_usermem(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, ip2_RowIndex,  ip2_ColumnIndex, dp2_HessianValue);
		}

		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		vector<unsigned int> RowIndex;
		vector<unsigned int> ColumnIndex;
		vector<double> HessianValue;


		int returnValue = IndirectRecover_CoordinateFormat_vectors(g, dp2_CompressedMatrix, uip2_HessianSparsityPattern, RowIndex, ColumnIndex, HessianValue);

		unsigned int numOfNonZeros = returnValue;

		for(size_t i=0; i < numOfNonZeros; i++) {
			(*ip2_RowIndex)[i] = RowIndex[i];
			(*ip2_ColumnIndex)[i] = ColumnIndex[i];
			(*dp2_HessianValue)[i] = HessianValue[i];
		}

		return (returnValue);
	}

	int HessianRecovery::IndirectRecover_CoordinateFormat(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_HessianValue) {
//#define DEBUG 5103
		int returnValue = IndirectRecover_CoordinateFormat_unmanaged( g,  dp2_CompressedMatrix,  uip2_HessianSparsityPattern,  ip2_RowIndex,  ip2_ColumnIndex,  dp2_HessianValue);

		if(CF_available) reset();

		CF_available = true;
		i_CF_rowCount = returnValue;
		ip_CF_RowIndex = *ip2_RowIndex;
		ip_CF_ColumnIndex = *ip2_ColumnIndex;
		dp_CF_Value = *dp2_HessianValue;

		return (returnValue);
	}
}
