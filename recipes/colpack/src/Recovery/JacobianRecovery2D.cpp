/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "ColPackHeaders.h"

using namespace std;

namespace ColPack
{

	int JacobianRecovery2D::DirectRecover_RowCompressedFormat_usermem(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();

		vector<int> vi_LeftVertexColors;
		g->GetLeftVertexColors(vi_LeftVertexColors);

		vector<int> RightVertexColors_Transformed;
		g->GetRightVertexColors_Transformed(RightVertexColors_Transformed);

		int i_ColumnColorCount = g->GetRightVertexColorCount();
		if (g->GetRightVertexDefaultColor() == 1) i_ColumnColorCount--; //color ID 0 is used, ignore it

		//Do (column-)color statistic for each row, i.e., see how many elements in that row has color 0, color 1 ...
		int** colorStatistic = new int*[rowCount];	//color statistic for each row. For example, colorStatistic[0] is color statistic for row 0
													//If row 0 has 5 columns with color 3 => colorStatistic[0][3] = 5;
		//Allocate memory for colorStatistic[rowCount][colorCount] and initilize the matrix
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			colorStatistic[i] = new int[i_ColumnColorCount];
			for(unsigned int j=0; j < (unsigned int)i_ColumnColorCount; j++) colorStatistic[i][j] = 0;
		}

		//populate colorStatistic for right (column) vertices
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			int numOfNonZeros = uip2_JacobianSparsityPattern[i][0];
			for(unsigned int j=1; j <= (unsigned int)numOfNonZeros; j++) {
				//non-zero in the Jacobian: [i][uip2_JacobianSparsityPattern[i][j]]
				//color of that column: RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1
				if (RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]] > 0) {
					colorStatistic[i][RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1]++;
				}
			}
		}

		//Recover value of the Jacobian from dp2_ColumnCompressedMatrix (priority) and dp2_RowCompressedMatrix
//cout<<"Recover value of the Jacobian from dp2_ColumnCompressedMatrix (priority) and dp2_RowCompressedMatrix"<<endl;
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			unsigned int numOfNonZeros = uip2_JacobianSparsityPattern[i][0];
			for(unsigned int j=1; j <= numOfNonZeros; j++) {
//printf("Recover uip2_JacobianSparsityPattern[%d][%d] = %d \n", i, j, uip2_JacobianSparsityPattern[i][j]);
				// Check and see if we can recover the value from dp2_ColumnCompressedMatrix first
				if (RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]] > 0 &&
					colorStatistic[i][RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]] - 1]==1
					) {
//printf("\t from COLUMN [%d][%d] = %7.2f \n",i, RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1, dp2_ColumnCompressedMatrix[i][RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1]);
//printf("\t from COLUMN [%d][%d] \n",i, RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1);
					(*dp3_JacobianValue)[i][j] = dp2_ColumnCompressedMatrix[i][RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1];
				}
				else { // If not, then use dp2_RowCompressedMatrix
//printf("\t from ROW [%d][%d] = %7.2f \n",m_vi_LeftVertexColors[i]-1, uip2_JacobianSparsityPattern[i][j], dp2_RowCompressedMatrix[m_vi_LeftVertexColors[i]-1][uip2_JacobianSparsityPattern[i][j]]);
//printf("\t from ROW [%d][%d] \n",m_vi_LeftVertexColors[i]-1, uip2_JacobianSparsityPattern[i][j]);
					(*dp3_JacobianValue)[i][j] = dp2_RowCompressedMatrix[vi_LeftVertexColors[i]-1][uip2_JacobianSparsityPattern[i][j]];
				}
			}

		}
//cout<<"DONE"<<endl;

		free_2DMatrix(colorStatistic, rowCount);
		colorStatistic = NULL;

		return rowCount;
	}

	int JacobianRecovery2D::DirectRecover_RowCompressedFormat_unmanaged(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();

		//allocate memory for *dp3_JacobianValue. The dp3_JacobianValue and uip2_JacobianSparsityPattern matrices should have the same size
//cout<<"allocate memory for *dp3_JacobianValue"<<endl;
		*dp3_JacobianValue = (double**) malloc(rowCount * sizeof(double*));
		for(int i=0; i < rowCount; i++) {
			int numOfNonZeros = uip2_JacobianSparsityPattern[i][0];
			(*dp3_JacobianValue)[i] = (double*) malloc( (numOfNonZeros+1) * sizeof(double) );
			(*dp3_JacobianValue)[i][0] = numOfNonZeros; //initialize value of the 1st entry
			for(int j=1; j <= numOfNonZeros; j++) (*dp3_JacobianValue)[i][j] = 0.; //initialize value of other entries
		}

		return DirectRecover_RowCompressedFormat_usermem(g, dp2_RowCompressedMatrix, dp2_ColumnCompressedMatrix, uip2_JacobianSparsityPattern, dp3_JacobianValue);
	}

	int JacobianRecovery2D::DirectRecover_RowCompressedFormat(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue) {
		int returnValue = DirectRecover_RowCompressedFormat_unmanaged(g,  dp2_RowCompressedMatrix,  dp2_ColumnCompressedMatrix,  uip2_JacobianSparsityPattern,  dp3_JacobianValue);

		if(AF_available) {
			//cout<<"AF_available="<<AF_available<<endl; Pause();
			reset();
		}


		AF_available = true;
		i_AF_rowCount = g->GetRowVertexCount();
		dp2_AF_Value = *dp3_JacobianValue;

		return returnValue;
	}

//*/


	int JacobianRecovery2D::DirectRecover_SparseSolversFormat_usermem(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();

		//Making the array indices to start at 0 instead of 1
		for(unsigned int i=0; i <= (unsigned int) rowCount ; i++) {
		  (*ip2_RowIndex)[i]--;
		}
		for(unsigned int i=0; i < (unsigned int)g->GetEdgeCount(); i++) {
		  (*ip2_ColumnIndex)[i]--;
		}

		vector<int> vi_LeftVertexColors;
		g->GetLeftVertexColors(vi_LeftVertexColors);

		vector<int> RightVertexColors_Transformed;
		g->GetRightVertexColors_Transformed(RightVertexColors_Transformed);

		int i_ColumnColorCount = g->GetRightVertexColorCount();
		if (g->GetRightVertexDefaultColor() == 1) i_ColumnColorCount--; //color ID 0 is used, ignore it


		//Do (column-)color statistic for each row, i.e., see how many elements in that row has color 0, color 1 ...
		int** colorStatistic = new int*[rowCount];	//color statistic for each row. For example, colorStatistic[0] is color statistic for row 0
													//If row 0 has 5 columns with color 3 => colorStatistic[0][3] = 5;
		//Allocate memory for colorStatistic[rowCount][colorCount] and initilize the matrix
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			colorStatistic[i] = new int[i_ColumnColorCount];
			for(unsigned int j=0; j < (unsigned int)i_ColumnColorCount; j++) colorStatistic[i][j] = 0;
		}

		//populate colorStatistic for right (column) vertices
		unsigned int numOfNonZeros = 0;
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			numOfNonZeros = (unsigned int)uip2_JacobianSparsityPattern[i][0];
			for(unsigned int j=1; j <= numOfNonZeros; j++) {
				//non-zero in the Jacobian: [i][uip2_JacobianSparsityPattern[i][j]]
				//color of that column: RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1
				if (RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]] > 0) {
					colorStatistic[i][RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1]++;
				}
			}
		}



		//Recover value of the Jacobian from dp2_ColumnCompressedMatrix (priority) and dp2_RowCompressedMatrix
//cout<<"Recover value of the Jacobian from dp2_ColumnCompressedMatrix (priority) and dp2_RowCompressedMatrix"<<endl;
		unsigned int numOfNonZerosInEachRow = 0;
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			numOfNonZerosInEachRow = uip2_JacobianSparsityPattern[i][0];
			for(unsigned int j=1; j <= numOfNonZerosInEachRow; j++) {
//printf("Recover uip2_JacobianSparsityPattern[%d][%d] = %d \n", i, j, uip2_JacobianSparsityPattern[i][j]);
				// Check and see if we can recover the value from dp2_ColumnCompressedMatrix first
				if (RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]] > 0 &&
					colorStatistic[i][RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]] - 1]==1
					) {
//printf("\t from COLUMN [%d][%d] = %7.2f \n",i, RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1, dp2_ColumnCompressedMatrix[i][RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1]);
//printf("\t from COLUMN [%d][%d] \n",i, RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1);
					(*dp2_JacobianValue)[(*ip2_RowIndex)[i]+j-1] = dp2_ColumnCompressedMatrix[i][RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1];
				}
				else { // If not, then use dp2_RowCompressedMatrix
//printf("\t from ROW [%d][%d] = %7.2f \n",m_vi_LeftVertexColors[i]-1, uip2_JacobianSparsityPattern[i][j], dp2_RowCompressedMatrix[m_vi_LeftVertexColors[i]-1][uip2_JacobianSparsityPattern[i][j]]);
//printf("\t from ROW [%d][%d] \n",m_vi_LeftVertexColors[i]-1, uip2_JacobianSparsityPattern[i][j]);
					(*dp2_JacobianValue)[(*ip2_RowIndex)[i]+j-1] = dp2_RowCompressedMatrix[vi_LeftVertexColors[i]-1][uip2_JacobianSparsityPattern[i][j]];
				}
			}

		}
//cout<<"DONE"<<endl;


		//Making the array indices to start at 1 instead of 0 to conform with theIntel MKL sparse storage scheme for the direct sparse solvers
		for(unsigned int i=0; i <= (unsigned int) rowCount ; i++) {
		  (*ip2_RowIndex)[i]++;
		}
		for(unsigned int i=0; i < (unsigned int)g->GetEdgeCount(); i++) {
		  (*ip2_ColumnIndex)[i]++;
		}


		free_2DMatrix(colorStatistic, rowCount);
		colorStatistic = NULL;

		return rowCount;
	}

	int JacobianRecovery2D::DirectRecover_SparseSolversFormat_unmanaged(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();

		// Allocate memory and populate ip2_RowIndex and ip2_ColumnIndex
		g->GetRowVertices(ip2_RowIndex);
		unsigned int numOfNonZeros = g->GetColumnIndices(ip2_ColumnIndex);

		//Making the array indices to start at 1 instead of 0 to conform with theIntel MKL sparse storage scheme for the direct sparse solvers
		for(unsigned int i=0; i <= (unsigned int) rowCount ; i++) {
		  (*ip2_RowIndex)[i]++;
		}
		for(unsigned int i=0; i < numOfNonZeros; i++) {
		  (*ip2_ColumnIndex)[i]++;
		}

		//cout<<"allocate memory for *dp2_JacobianValue rowCount="<<rowCount<<endl;
		//printf("i=%d\tnumOfNonZeros=%d \n", i, numOfNonZeros);
		(*dp2_JacobianValue) = (double*) malloc(numOfNonZeros * sizeof(double)); //allocate memory for *dp2_JacobianValue.
		for(unsigned int i=0; i < numOfNonZeros; i++) (*dp2_JacobianValue)[i] = 0.; //initialize value of other entries

		return DirectRecover_SparseSolversFormat_usermem(g, dp2_RowCompressedMatrix, dp2_ColumnCompressedMatrix, uip2_JacobianSparsityPattern, ip2_RowIndex, ip2_ColumnIndex, dp2_JacobianValue);
	}

	int JacobianRecovery2D::DirectRecover_SparseSolversFormat(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		int returnValue = DirectRecover_SparseSolversFormat_unmanaged(g,  dp2_RowCompressedMatrix,  dp2_ColumnCompressedMatrix,  uip2_JacobianSparsityPattern,  ip2_RowIndex,  ip2_ColumnIndex,  dp2_JacobianValue);

		if(SSF_available) {
			//cout<<"SSF_available="<<SSF_available<<endl; Pause();
			reset();
		}

		SSF_available = true;
		i_SSF_rowCount = g->GetRowVertexCount();
		ip_SSF_RowIndex = *ip2_RowIndex;
		ip_SSF_ColumnIndex = *ip2_ColumnIndex;
		dp_SSF_Value = *dp2_JacobianValue;

		return returnValue;
	}

//*/



	int JacobianRecovery2D::DirectRecover_CoordinateFormat_usermem(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();

		vector<int> vi_LeftVertexColors;
		g->GetLeftVertexColors(vi_LeftVertexColors);

		vector<int> RightVertexColors_Transformed;
		g->GetRightVertexColors_Transformed(RightVertexColors_Transformed);

		int i_ColumnColorCount = g->GetRightVertexColorCount();
		if (g->GetRightVertexDefaultColor() == 1) i_ColumnColorCount--; //color ID 0 is used, ignore it

		//Do (column-)color statistic for each row, i.e., see how many elements in that row has color 0, color 1 ...
		int** colorStatistic = new int*[rowCount];	//color statistic for each row. For example, colorStatistic[0] is color statistic for row 0
													//If row 0 has 5 columns with color 3 => colorStatistic[0][3] = 5;
		//Allocate memory for colorStatistic[rowCount][colorCount] and initilize the matrix
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			colorStatistic[i] = new int[i_ColumnColorCount];
			for(unsigned int j=0; j < (unsigned int)i_ColumnColorCount; j++) colorStatistic[i][j] = 0;
		}

		//populate colorStatistic for right (column) vertices
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			int numOfNonZeros = uip2_JacobianSparsityPattern[i][0];
			for(unsigned int j=1; j <= (unsigned int)numOfNonZeros; j++) {
				//non-zero in the Jacobian: [i][uip2_JacobianSparsityPattern[i][j]]
				//color of that column: m_vi_RightVertexColors[uip2_JacobianSparsityPattern[i][j]]-1
				if (RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]] > 0) {
					colorStatistic[i][RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1]++;
				}
			}
		}

		//Recover value of the Jacobian from dp2_ColumnCompressedMatrix (priority) and dp2_RowCompressedMatrix
//cout<<"Recover value of the Jacobian from dp2_ColumnCompressedMatrix (priority) and dp2_RowCompressedMatrix"<<endl;
		unsigned int numOfNonZeros_count = 0;
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			unsigned int numOfNonZeros = uip2_JacobianSparsityPattern[i][0];
			for(unsigned int j=1; j <= numOfNonZeros; j++) {
//printf("Recover uip2_JacobianSparsityPattern[%d][%d] = %d \n", i, j, uip2_JacobianSparsityPattern[i][j]);
				// Check and see if we can recover the value from dp2_ColumnCompressedMatrix first
				if (RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]] > 0 &&
					colorStatistic[i][RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]] - 1]==1
					) {
//printf("\t from COLUMN [%d][%d] = %7.2f \n",i, RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1, dp2_ColumnCompressedMatrix[i][RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1]);
//printf("\t from COLUMN [%d][%d] \n",i, RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1);
					(*dp2_JacobianValue)[numOfNonZeros_count] = dp2_ColumnCompressedMatrix[i][RightVertexColors_Transformed[uip2_JacobianSparsityPattern[i][j]]-1];
				}
				else { // If not, then use dp2_RowCompressedMatrix
//printf("\t from ROW [%d][%d] = %7.2f \n",m_vi_LeftVertexColors[i]-1, uip2_JacobianSparsityPattern[i][j], dp2_RowCompressedMatrix[m_vi_LeftVertexColors[i]-1][uip2_JacobianSparsityPattern[i][j]]);
//printf("\t from ROW [%d][%d] \n",m_vi_LeftVertexColors[i]-1, uip2_JacobianSparsityPattern[i][j]);
					(*dp2_JacobianValue)[numOfNonZeros_count] = dp2_RowCompressedMatrix[vi_LeftVertexColors[i]-1][uip2_JacobianSparsityPattern[i][j]];
				}
				(*ip2_RowIndex)[numOfNonZeros_count] = i;
				(*ip2_ColumnIndex)[numOfNonZeros_count] = uip2_JacobianSparsityPattern[i][j];
				numOfNonZeros_count++;
			}

		}
//cout<<"DONE"<<endl;

		free_2DMatrix(colorStatistic, rowCount);
		colorStatistic = NULL;

		return numOfNonZeros_count;
	}

	int JacobianRecovery2D::DirectRecover_CoordinateFormat_unmanaged(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		unsigned int numOfNonZeros = g->GetEdgeCount();
		(*ip2_RowIndex) = (unsigned int*) malloc(numOfNonZeros * sizeof(unsigned int));
		(*ip2_ColumnIndex) = (unsigned int*) malloc(numOfNonZeros * sizeof(unsigned int));
		(*dp2_JacobianValue) = (double*) malloc(numOfNonZeros * sizeof(double)); //allocate memory for *dp2_JacobianValue.

		return DirectRecover_CoordinateFormat_usermem(g, dp2_RowCompressedMatrix, dp2_ColumnCompressedMatrix, uip2_JacobianSparsityPattern, ip2_RowIndex, ip2_ColumnIndex, dp2_JacobianValue);
	}

	int JacobianRecovery2D::DirectRecover_CoordinateFormat(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		int returnValue = DirectRecover_CoordinateFormat_unmanaged(g, dp2_RowCompressedMatrix, dp2_ColumnCompressedMatrix,  uip2_JacobianSparsityPattern, ip2_RowIndex,  ip2_ColumnIndex,  dp2_JacobianValue);

		if(CF_available) reset();

		CF_available = true;
		i_CF_rowCount = g->GetRowVertexCount();
		ip_CF_RowIndex = *ip2_RowIndex;
		ip_CF_ColumnIndex = *ip2_ColumnIndex;
		dp_CF_Value = *dp2_JacobianValue;

		return returnValue;
	}
}
