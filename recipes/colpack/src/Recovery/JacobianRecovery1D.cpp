/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "ColPackHeaders.h"

using namespace std;

namespace ColPack
{

	int JacobianRecovery1D::RecoverD2Row_RowCompressedFormat_unmanaged(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();
		unsigned int numOfNonZeros = 0;

		//allocate memory for *dp3_JacobianValue. The dp3_JacobianValue and uip2_JacobianSparsityPattern matrices should have the same size
		*dp3_JacobianValue = (double**) malloc(rowCount * sizeof(double*));
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			numOfNonZeros = uip2_JacobianSparsityPattern[i][0];
			(*dp3_JacobianValue)[i] = (double*) malloc( (numOfNonZeros+1) * sizeof(double) );
			(*dp3_JacobianValue)[i][0] = numOfNonZeros; //initialize value of the 1st entry
			for(size_t j=1; j <=  numOfNonZeros; j++) (*dp3_JacobianValue)[i][j] = 0.; //initialize value of other entries
		}

		return RecoverD2Row_RowCompressedFormat_usermem(g, dp2_CompressedMatrix, uip2_JacobianSparsityPattern, dp3_JacobianValue);
	}

	int JacobianRecovery1D::RecoverD2Row_RowCompressedFormat_usermem(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();
		vector<int> vi_LeftVertexColors;
		g->GetLeftVertexColors(vi_LeftVertexColors);
		unsigned int numOfNonZeros = 0;

		//allocate memory for *dp3_JacobianValue. The dp3_JacobianValue and uip2_JacobianSparsityPattern matrices should have the same size
		//*dp3_JacobianValue = new double*[rowCount];
		//for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
		//	numOfNonZeros = uip2_JacobianSparsityPattern[i][0];
		//	(*dp3_JacobianValue)[i] = new double[numOfNonZeros+1];
		//	(*dp3_JacobianValue)[i][0] = numOfNonZeros; //initialize value of the 1st entry
		//	for(int j=1; j <= numOfNonZeros; j++) (*dp3_JacobianValue)[i][j] = 0.; //initialize value of other entries
		//}

		//Recover value of the Jacobian
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			numOfNonZeros = uip2_JacobianSparsityPattern[i][0];
			for(size_t j=1; j <= numOfNonZeros; j++) {
				(*dp3_JacobianValue)[i][j] = dp2_CompressedMatrix[vi_LeftVertexColors[i]][uip2_JacobianSparsityPattern[i][j]];
			}

		}

		return rowCount;
	}

	int JacobianRecovery1D::RecoverD2Row_RowCompressedFormat(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue) {
		int returnValue = RecoverD2Row_RowCompressedFormat_unmanaged(g, dp2_CompressedMatrix, uip2_JacobianSparsityPattern, dp3_JacobianValue);

		if(AF_available) reset();

		AF_available = true;
		i_AF_rowCount = g->GetRowVertexCount();
		dp2_AF_Value = *dp3_JacobianValue;

		return returnValue;
	}

	int JacobianRecovery1D::RecoverD2Row_SparseSolversFormat_usermem(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();
		vector<int> vi_LeftVertexColors;
		g->GetLeftVertexColors(vi_LeftVertexColors);
		unsigned int numOfNonZeros = 0;

		// Populate ip2_RowIndex and ip2_ColumnIndex
		//numOfNonZeros = g->GetColumnIndices(ip2_ColumnIndex);
		numOfNonZeros = g->GetEdgeCount();// !!!! make sure that this line is equivalent to the line above

		//Making the array indices to start at 0 instead of 1
		for(unsigned int i=0; i <= (unsigned int)rowCount; i++) {
		  (*ip2_RowIndex)[i]--;
		}
		for(unsigned int i=0; i < numOfNonZeros; i++) {
		  (*ip2_ColumnIndex)[i]--;
		}

		//Recover value of the Jacobian
		unsigned int numOfNonZerosInEachRow = 0;
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			numOfNonZerosInEachRow = uip2_JacobianSparsityPattern[i][0];
			for(size_t j=1; j <= numOfNonZerosInEachRow; j++) {
				(*dp2_JacobianValue)[(*ip2_RowIndex)[i]+j-1] = dp2_CompressedMatrix[vi_LeftVertexColors[i]][uip2_JacobianSparsityPattern[i][j]];
			}

		}

		//Making the array indices to start at 1 instead of 0 to conform with theIntel MKL sparse storage scheme for the direct sparse solvers
		for(unsigned int i=0; i <= (unsigned int)rowCount; i++) {
		  (*ip2_RowIndex)[i]++;
		}
		for(unsigned int i=0; i < numOfNonZeros; i++) {
		  (*ip2_ColumnIndex)[i]++;
		}

		return rowCount;
	}

	int JacobianRecovery1D::RecoverD2Row_SparseSolversFormat_unmanaged(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();
		unsigned int numOfNonZeros = 0;

		// Allocate memory and populate ip2_RowIndex and ip2_ColumnIndex
		g->GetRowVertices(ip2_RowIndex);
		numOfNonZeros = g->GetColumnIndices(ip2_ColumnIndex);

		//Making the array indices to start at 1 instead of 0 to conform with theIntel MKL sparse storage scheme for the direct sparse solvers
		for(unsigned int i=0; i <= (unsigned int)rowCount; i++) {
		  (*ip2_RowIndex)[i]++;
		}
		for(unsigned int i=0; i < numOfNonZeros; i++) {
		  (*ip2_ColumnIndex)[i]++;
		}

		(*dp2_JacobianValue) = (double*) malloc(numOfNonZeros * sizeof(double)); //allocate memory for *dp2_JacobianValue.
		for(unsigned int i=0; i < numOfNonZeros; i++) (*dp2_JacobianValue)[i] = 0.; //initialize value of other entries

		return RecoverD2Row_SparseSolversFormat_usermem(g, dp2_CompressedMatrix, uip2_JacobianSparsityPattern, ip2_RowIndex, ip2_ColumnIndex, dp2_JacobianValue);
	}

	int JacobianRecovery1D::RecoverD2Row_SparseSolversFormat(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		int returnValue = RecoverD2Row_SparseSolversFormat_unmanaged(g, dp2_CompressedMatrix, uip2_JacobianSparsityPattern, ip2_RowIndex, ip2_ColumnIndex, dp2_JacobianValue);

		if(SSF_available) reset();

		SSF_available = true;
		i_SSF_rowCount = g->GetRowVertexCount();
		ip_SSF_RowIndex = *ip2_RowIndex;
		ip_SSF_ColumnIndex = *ip2_ColumnIndex;
		dp_SSF_Value = *dp2_JacobianValue;

		return returnValue;
	}

	int JacobianRecovery1D::RecoverD2Row_CoordinateFormat_usermem(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();
		vector<int> vi_LeftVertexColors;
		g->GetLeftVertexColors(vi_LeftVertexColors);

		int numOfNonZeros;
		//vector<int>* LeftVerticesPtr = g->GetLeftVerticesPtr();

		//Recover value of the Jacobian

//		#pragma omp parallel for default(none) schedule(static) shared(rowCount,LeftVerticesPtr,dp2_JacobianValue, ip2_RowIndex, ip2_ColumnIndex, uip2_JacobianSparsityPattern, dp2_CompressedMatrix, vi_LeftVertexColors) private(numOfNonZeros)
/*		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			numOfNonZeros = uip2_JacobianSparsityPattern[i][0];
			for(int j=1; j <= numOfNonZeros; j++) {
				(*dp2_JacobianValue)[(*LeftVerticesPtr)[i]+j-1] = dp2_CompressedMatrix[vi_LeftVertexColors[i]][uip2_JacobianSparsityPattern[i][j]];
				(*ip2_RowIndex)[(*LeftVerticesPtr)[i]+j-1] = i;
				(*ip2_ColumnIndex)[(*LeftVerticesPtr)[i]+j-1] = uip2_JacobianSparsityPattern[i][j];

			}
		}
		if(numOfNonZeros_count != g->GetEdgeCount()) {
			cout<<"**Something fishing going on"<<endl;
			cout<<"numOfNonZeros_count="<<numOfNonZeros_count<<endl;
			cout<<"numOfNonZeros="<<g->GetEdgeCount()<<endl;
		}
		else cout<<"**Good!!!"<<endl;
		Pause();
		//

		return (*LeftVerticesPtr)[rowCount];
*/
		unsigned int numOfNonZeros_count = 0;
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			numOfNonZeros = uip2_JacobianSparsityPattern[i][0];
			for(int j=1; j <= numOfNonZeros; j++) {
				(*dp2_JacobianValue)[numOfNonZeros_count] = dp2_CompressedMatrix[vi_LeftVertexColors[i]][uip2_JacobianSparsityPattern[i][j]];
				(*ip2_RowIndex)[numOfNonZeros_count] = i;
				(*ip2_ColumnIndex)[numOfNonZeros_count] = uip2_JacobianSparsityPattern[i][j];
				numOfNonZeros_count++;
			}
		}
		/*
		if(numOfNonZeros_count != g->GetEdgeCount()) {
			cout<<"**Something fishing going on"<<endl;
			cout<<"numOfNonZeros_count="<<numOfNonZeros_count<<endl;
			cout<<"numOfNonZeros="<<g->GetEdgeCount()<<endl;
		}
		else cout<<"**Good!!!"<<endl;
		Pause();
		// */
		return numOfNonZeros_count;

	}
/*
	int JacobianRecovery1D::RecoverD2Row_CoordinateFormat_usermem_serial(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();
		vector<int> vi_LeftVertexColors;
		g->GetLeftVertexColors(vi_LeftVertexColors);

		int numOfNonZeros;

		//Recover value of the Jacobian
		unsigned int numOfNonZeros_count = 0;
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			numOfNonZeros = uip2_JacobianSparsityPattern[i][0];
			for(int j=1; j <= numOfNonZeros; j++) {
				(*dp2_JacobianValue)[numOfNonZeros_count] = dp2_CompressedMatrix[vi_LeftVertexColors[i]][uip2_JacobianSparsityPattern[i][j]];
				(*ip2_RowIndex)[numOfNonZeros_count] = i;
				(*ip2_ColumnIndex)[numOfNonZeros_count] = uip2_JacobianSparsityPattern[i][j];
				numOfNonZeros_count++;
			}
		}
		if(numOfNonZeros_count != g->GetEdgeCount()) {
			cout<<"**Something fishing going on"<<endl;
			cout<<"numOfNonZeros_count="<<numOfNonZeros_count<<endl;
			cout<<"numOfNonZeros="<<g->GetEdgeCount()<<endl;
		}
		else cout<<"**Good!!!"<<endl;
		Pause();

		return numOfNonZeros_count;
	}
*/
/*
	int JacobianRecovery1D::RecoverD2Row_CoordinateFormat_unmanaged_OMP(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {

		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		unsigned int numOfNonZeros =  g->GetEdgeCount();

		// !!! test the effectiveness of this sections. Will I really get any improvement
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
		    (*dp2_JacobianValue) = (double*) malloc(numOfNonZeros * sizeof(double)); //allocate memory for *dp2_JacobianValue.
		  }
		}
		return RecoverD2Row_CoordinateFormat_usermem(g, dp2_CompressedMatrix, uip2_JacobianSparsityPattern, ip2_RowIndex, ip2_ColumnIndex, dp2_JacobianValue);
	}
*/
	int JacobianRecovery1D::RecoverD2Row_CoordinateFormat_unmanaged(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		unsigned int numOfNonZeros =  g->GetEdgeCount();

		(*ip2_RowIndex) = (unsigned int*) malloc(numOfNonZeros * sizeof(unsigned int));
		(*ip2_ColumnIndex) = (unsigned int*) malloc(numOfNonZeros * sizeof(unsigned int));
		(*dp2_JacobianValue) = (double*) malloc(numOfNonZeros * sizeof(double)); //allocate memory for *dp2_JacobianValue.

//		return RecoverD2Row_CoordinateFormat_usermem_serial(g, dp2_CompressedMatrix, uip2_JacobianSparsityPattern, ip2_RowIndex, ip2_ColumnIndex, dp2_JacobianValue);
		return RecoverD2Row_CoordinateFormat_usermem(g, dp2_CompressedMatrix, uip2_JacobianSparsityPattern, ip2_RowIndex, ip2_ColumnIndex, dp2_JacobianValue);
	}
/*
	int JacobianRecovery1D::RecoverD2Row_CoordinateFormat_OMP(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		int returnValue = RecoverD2Row_CoordinateFormat_unmanaged_OMP(g, dp2_CompressedMatrix, uip2_JacobianSparsityPattern,  ip2_RowIndex,  ip2_ColumnIndex,  dp2_JacobianValue);

		if(CF_available) reset();

		CF_available = true;
		i_CF_rowCount = g->GetRowVertexCount();
		ip_CF_RowIndex = *ip2_RowIndex;
		ip_CF_ColumnIndex = *ip2_ColumnIndex;
		dp_CF_Value = *dp2_JacobianValue;

		return returnValue;
	}
*/
	int JacobianRecovery1D::RecoverD2Row_CoordinateFormat(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		int returnValue = RecoverD2Row_CoordinateFormat_unmanaged(g, dp2_CompressedMatrix, uip2_JacobianSparsityPattern,  ip2_RowIndex,  ip2_ColumnIndex,  dp2_JacobianValue);

		if(CF_available) reset();

		CF_available = true;
		i_CF_rowCount = g->GetRowVertexCount();
		ip_CF_RowIndex = *ip2_RowIndex;
		ip_CF_ColumnIndex = *ip2_ColumnIndex;
		dp_CF_Value = *dp2_JacobianValue;

		return returnValue;
	}

	int JacobianRecovery1D::RecoverD2Cln_ADICFormat(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, std::list<std::set<int> >& lsi_SparsityPattern, std::list<std::vector<double> > &lvd_NewValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();
		vector<int> vi_RightVertexColors;
		g->GetRightVertexColors(vi_RightVertexColors);
		unsigned int numOfNonZeros = 0;
		std::list<std::set<int> >::iterator lsii_SparsityPattern = lsi_SparsityPattern.begin();

		//Recover value of the Jacobian
		//cout<<"Recover value of the Jacobian"<<endl;
		for(unsigned int i=0; i < (unsigned int)rowCount; lsii_SparsityPattern++, i++) {
			std::set<int> valset = *lsii_SparsityPattern;
			std::set<int>::iterator valsetiter = valset.begin();
			numOfNonZeros = valset.size(); //(*lsii_SparsityPattern) is equivalent to uip2_JacobianSparsityPattern[i]
			std::vector<double> valuevector;
			valuevector.resize(numOfNonZeros);
			for(unsigned int j=0; j < numOfNonZeros; valsetiter++, j++) {
				valuevector[j] = dp2_CompressedMatrix[i][vi_RightVertexColors[*valsetiter]];
			}

			lvd_NewValue.push_back(valuevector);
		}

		return rowCount;
	}

	int JacobianRecovery1D::RecoverD2Cln_RowCompressedFormat_usermem(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();
		vector<int> vi_RightVertexColors;
		g->GetRightVertexColors(vi_RightVertexColors);
		unsigned int numOfNonZeros = 0;

		//Recover value of the Jacobian
		//cout<<"Recover value of the Jacobian"<<endl;
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			numOfNonZeros = uip2_JacobianSparsityPattern[i][0];
			for(unsigned int j=1; j <= numOfNonZeros; j++) {
				(*dp3_JacobianValue)[i][j] = dp2_CompressedMatrix[i][vi_RightVertexColors[uip2_JacobianSparsityPattern[i][j]]];
			}

		}

		return rowCount;
	}

	int JacobianRecovery1D::RecoverD2Cln_RowCompressedFormat_unmanaged(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();
		unsigned int numOfNonZeros = 0;

		//allocate memory for *dp3_JacobianValue. The dp3_JacobianValue and uip2_JacobianSparsityPattern matrices should have the same size
		//cout<<"allocate memory for *dp3_JacobianValue rowCount="<<rowCount<<endl;
		*dp3_JacobianValue = (double**) malloc(rowCount * sizeof(double*));
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			numOfNonZeros = uip2_JacobianSparsityPattern[i][0];
			//printf("i=%d\tnumOfNonZeros=%d \n", i, numOfNonZeros);
			(*dp3_JacobianValue)[i] = (double*) malloc( (numOfNonZeros+1) * sizeof(double) );
			(*dp3_JacobianValue)[i][0] = numOfNonZeros; //initialize value of the 1st entry
			for(unsigned int j=1; j <= numOfNonZeros; j++) (*dp3_JacobianValue)[i][j] = 0.; //initialize value of other entries
		}

		return RecoverD2Cln_RowCompressedFormat_usermem(g, dp2_CompressedMatrix, uip2_JacobianSparsityPattern, dp3_JacobianValue);
	}

	int JacobianRecovery1D::RecoverD2Cln_RowCompressedFormat(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue) {
		int returnValue = RecoverD2Cln_RowCompressedFormat_unmanaged(g,  dp2_CompressedMatrix,  uip2_JacobianSparsityPattern,  dp3_JacobianValue);

		if(AF_available) reset();

		AF_available = true;
		i_AF_rowCount = g->GetRowVertexCount();
		dp2_AF_Value = *dp3_JacobianValue;

		return returnValue;
	}

	int JacobianRecovery1D::RecoverD2Cln_SparseSolversFormat_usermem(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();
		vector<int> vi_RightVertexColors;
		g->GetRightVertexColors(vi_RightVertexColors);
		unsigned int numOfNonZeros = 0;

		numOfNonZeros = g->GetEdgeCount();

		//Making the array indices to start at 0 instead of 1
		for(unsigned int i=0; i <= (unsigned int)rowCount; i++) {
		  (*ip2_RowIndex)[i]--;
		}
		for(unsigned int i=0; i < numOfNonZeros; i++) {
		  (*ip2_ColumnIndex)[i]--;
		}

		//Recover value of the Jacobian
		//cout<<"Recover value of the Jacobian"<<endl;
		unsigned int numOfNonZerosInEachRow = 0;
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			numOfNonZerosInEachRow = uip2_JacobianSparsityPattern[i][0];
			for(unsigned int j=1; j <= numOfNonZerosInEachRow; j++) {
				(*dp2_JacobianValue)[(*ip2_RowIndex)[i]+j-1] = dp2_CompressedMatrix[i][vi_RightVertexColors[uip2_JacobianSparsityPattern[i][j]]];
			}
		}

		//Making the array indices to start at 1 instead of 0 to conform with theIntel MKL sparse storage scheme for the direct sparse solvers
		for(unsigned int i=0; i <= (unsigned int)rowCount; i++) {
		  (*ip2_RowIndex)[i]++;
		}
		for(unsigned int i=0; i < numOfNonZeros; i++) {
		  (*ip2_ColumnIndex)[i]++;
		}

		return rowCount;
	}

	int JacobianRecovery1D::RecoverD2Cln_SparseSolversFormat_unmanaged(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();
		unsigned int numOfNonZeros = 0;

		// Allocate memory and populate ip2_RowIndex and ip2_ColumnIndex
		g->GetRowVertices(ip2_RowIndex);
		numOfNonZeros = g->GetColumnIndices(ip2_ColumnIndex);

		//Making the array indices to start at 1 instead of 0 to conform with theIntel MKL sparse storage scheme for the direct sparse solvers
		for(unsigned int i=0; i <= (unsigned int)rowCount; i++) {
		  (*ip2_RowIndex)[i]++;
		}
		for(unsigned int i=0; i < numOfNonZeros; i++) {
		  (*ip2_ColumnIndex)[i]++;
		}

		//cout<<"allocate memory for *dp2_JacobianValue rowCount="<<rowCount<<endl;
		//printf("i=%d\tnumOfNonZeros=%d \n", i, numOfNonZeros);
		(*dp2_JacobianValue) = (double*) malloc(numOfNonZeros * sizeof(double)); //allocate memory for *dp2_JacobianValue.
		for(unsigned int i=0; i < numOfNonZeros; i++) (*dp2_JacobianValue)[i] = 0.; //initialize value of other entries

		return RecoverD2Cln_SparseSolversFormat_usermem(g, dp2_CompressedMatrix, uip2_JacobianSparsityPattern, ip2_RowIndex, ip2_ColumnIndex, dp2_JacobianValue);
	}

	int JacobianRecovery1D::RecoverD2Cln_SparseSolversFormat(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		int returnValue = RecoverD2Cln_SparseSolversFormat_unmanaged( g,  dp2_CompressedMatrix,  uip2_JacobianSparsityPattern, ip2_RowIndex,  ip2_ColumnIndex,  dp2_JacobianValue);

		if(SSF_available) reset();

		SSF_available = true;
		i_SSF_rowCount = g->GetRowVertexCount();
		ip_SSF_RowIndex = *ip2_RowIndex;
		ip_SSF_ColumnIndex = *ip2_ColumnIndex;
		dp_SSF_Value = *dp2_JacobianValue;

		return returnValue;
	}

	int JacobianRecovery1D::RecoverD2Cln_CoordinateFormat_usermem(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();
		vector<int> vi_RightVertexColors;
		g->GetRightVertexColors(vi_RightVertexColors);
		unsigned int numOfNonZeros = 0;
//		vector<int>* LeftVerticesPtr = g->GetLeftVerticesPtr();

		//Recover value of the Jacobian
		//cout<<"Recover value of the Jacobian"<<endl;
//		#pragma omp parallel for default(none) schedule(static) shared(rowCount,LeftVerticesPtr,dp2_JacobianValue, ip2_RowIndex, ip2_ColumnIndex, uip2_JacobianSparsityPattern, dp2_CompressedMatrix, vi_RightVertexColors) private(numOfNonZeros)
/*		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			numOfNonZeros = uip2_JacobianSparsityPattern[i][0];
			for(unsigned int j=1; j <= numOfNonZeros; j++) {
				(*dp2_JacobianValue)[(*LeftVerticesPtr)[i]+j-1] = dp2_CompressedMatrix[i][vi_RightVertexColors[uip2_JacobianSparsityPattern[i][j]]];
				(*ip2_RowIndex)[(*LeftVerticesPtr)[i]+j-1] = i;
				(*ip2_ColumnIndex)[(*LeftVerticesPtr)[i]+j-1] = uip2_JacobianSparsityPattern[i][j];
			}
		}

		return (*LeftVerticesPtr)[rowCount];
*/
		unsigned int numOfNonZeros_count = 0;
		//unsigned int ll=0;
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			numOfNonZeros = uip2_JacobianSparsityPattern[i][0];
			for(unsigned int j=1; j <= numOfNonZeros; j++) {
				(*dp2_JacobianValue)[numOfNonZeros_count] = dp2_CompressedMatrix[i][vi_RightVertexColors[uip2_JacobianSparsityPattern[i][j]]];
				(*ip2_RowIndex)[numOfNonZeros_count] = i;
				(*ip2_ColumnIndex)[numOfNonZeros_count] = uip2_JacobianSparsityPattern[i][j];
				numOfNonZeros_count++;
			}
		}

		return numOfNonZeros_count;

	}
/*
	int JacobianRecovery1D::RecoverD2Cln_CoordinateFormat_usermem_serial(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		int rowCount = g->GetRowVertexCount();
		vector<int> vi_RightVertexColors;
		g->GetRightVertexColors(vi_RightVertexColors);
		unsigned int numOfNonZeros = 0;

		//Recover value of the Jacobian
		//cout<<"Recover value of the Jacobian"<<endl;
		unsigned int numOfNonZeros_count = 0;
		for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
			numOfNonZeros = uip2_JacobianSparsityPattern[i][0];
			for(unsigned int j=1; j <= numOfNonZeros; j++) {
				(*dp2_JacobianValue)[numOfNonZeros_count] = dp2_CompressedMatrix[i][vi_RightVertexColors[uip2_JacobianSparsityPattern[i][j]]];
				(*ip2_RowIndex)[numOfNonZeros_count] = i;
				(*ip2_ColumnIndex)[numOfNonZeros_count] = uip2_JacobianSparsityPattern[i][j];
				numOfNonZeros_count++;
			}
		}

		return numOfNonZeros_count;
	}
*/
/*
	int JacobianRecovery1D::RecoverD2Cln_CoordinateFormat_unmanaged_OMP(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		unsigned int numOfNonZeros = g->GetEdgeCount();

		// !!! test the effectiveness of this sections. Will I really get any improvement?
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
		    (*dp2_JacobianValue) = (double*) malloc(numOfNonZeros * sizeof(double)); //allocate memory for *dp2_JacobianValue.
		  }
		}

		return RecoverD2Cln_CoordinateFormat_usermem(g, dp2_CompressedMatrix, uip2_JacobianSparsityPattern, ip2_RowIndex, ip2_ColumnIndex, dp2_JacobianValue);
	}
*/
	int JacobianRecovery1D::RecoverD2Cln_CoordinateFormat_unmanaged(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		if(g==NULL) {
			cerr<<"g==NULL"<<endl;
			return _FALSE;
		}

		unsigned int numOfNonZeros = g->GetEdgeCount();

		(*ip2_RowIndex) = (unsigned int*) malloc(numOfNonZeros * sizeof(unsigned int));
		(*ip2_ColumnIndex) = (unsigned int*) malloc(numOfNonZeros * sizeof(unsigned int));
		(*dp2_JacobianValue) = (double*) malloc(numOfNonZeros * sizeof(double)); //allocate memory for *dp2_JacobianValue.

//		return RecoverD2Cln_CoordinateFormat_usermem_serial(g, dp2_CompressedMatrix, uip2_JacobianSparsityPattern, ip2_RowIndex, ip2_ColumnIndex, dp2_JacobianValue);

		return RecoverD2Cln_CoordinateFormat_usermem(g, dp2_CompressedMatrix, uip2_JacobianSparsityPattern, ip2_RowIndex, ip2_ColumnIndex, dp2_JacobianValue);
	}
/*
	int JacobianRecovery1D::RecoverD2Cln_CoordinateFormat_OMP(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		int returnValue = RecoverD2Cln_CoordinateFormat_unmanaged_OMP(g,  dp2_CompressedMatrix,  uip2_JacobianSparsityPattern,  ip2_RowIndex,  ip2_ColumnIndex,  dp2_JacobianValue);

		if(CF_available) reset();

		CF_available = true;
		i_CF_rowCount = g->GetRowVertexCount();
		ip_CF_RowIndex = *ip2_RowIndex;
		ip_CF_ColumnIndex = *ip2_ColumnIndex;
		dp_CF_Value = *dp2_JacobianValue;

		return returnValue;
	}
*/
	int JacobianRecovery1D::RecoverD2Cln_CoordinateFormat(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue) {
		int returnValue = RecoverD2Cln_CoordinateFormat_unmanaged(g,  dp2_CompressedMatrix,  uip2_JacobianSparsityPattern,  ip2_RowIndex,  ip2_ColumnIndex,  dp2_JacobianValue);

		if(CF_available) reset();

		CF_available = true;
		i_CF_rowCount = g->GetRowVertexCount();
		ip_CF_RowIndex = *ip2_RowIndex;
		ip_CF_ColumnIndex = *ip2_ColumnIndex;
		dp_CF_Value = *dp2_JacobianValue;

		return returnValue;
	}

	int JacobianRecovery1D::CompareMatrix_CoordinateFormat_vs_CoordinateFormat(int i_rowCount, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue, unsigned int** ip2_RowIndex2, unsigned int** ip2_ColumnIndex2, double** dp2_JacobianValue2) {
		bool fail_flag=false;
		for(int i=0;i<i_rowCount;i++) {
		  if((*ip2_RowIndex)[i]!=(*ip2_RowIndex2)[i]) {
		    cout<<"i="<<i<<" (*ip2_RowIndex)[i] ("<< (*ip2_RowIndex)[i] <<")!=(*ip2_RowIndex2)[i] ("<< (*ip2_RowIndex2)[i] <<")"<<endl;
		    fail_flag=true;
		    break;
		  }

		  if((*ip2_ColumnIndex)[i]!=(*ip2_ColumnIndex2)[i]) {
		    cout<<"i="<<i<<" (*ip2_ColumnIndex)[i] ("<< (*ip2_ColumnIndex)[i] <<")!=(*ip2_ColumnIndex2)[i] ("<< (*ip2_ColumnIndex2)[i] <<")"<<endl;
		    fail_flag=true;
		    break;
		  }


		  if((*dp2_JacobianValue)[i] != (*dp2_JacobianValue2)[i] ) {
		    cout<<"i="<<i<<" (*dp2_JacobianValue)[i] ("<< (*dp2_JacobianValue)[i] <<")!=(*dp2_JacobianValue2)[i] ("<< (*dp2_JacobianValue2)[i] <<")"<<endl;
		    fail_flag=true;
		    break;
		  }

		}

		return (fail_flag)?0:1;
	}

	int JacobianRecovery1D::CompareMatrix_CoordinateFormat_vs_RowCompressedFormat(int i_rowCount, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue,  int rowCount2, unsigned int *** uip3_SparsityPattern, double*** dp3_Value) {
		bool fail_flag=false;
		for(int i=0;i<i_rowCount;i++) {
		  if((*ip2_RowIndex)[i] >= (unsigned)rowCount2) {
		    fail_flag = true;
		    break;
		  }

		  size_t j =0;
		  for(;j<= (*uip3_SparsityPattern)[ (*ip2_RowIndex)[i] ][0];j++) {
		    if((*uip3_SparsityPattern)[ (*ip2_RowIndex)[i] ][j] == (*ip2_ColumnIndex)[i]) break;
		  }
		  if(j>(*uip3_SparsityPattern)[ (*ip2_RowIndex)[i] ][0]) {
		    fail_flag = true;
		    break;
		  }
		  //cout<<"found j = "<<j<<endl;

		  if( (*dp2_JacobianValue)[i] != (*dp3_Value)[(*ip2_RowIndex)[i]][j]) {
		    cout<<"i="<<i<<" (*dp2_JacobianValue)[i] ("<< (*dp2_JacobianValue)[i] <<")!=(*dp3_Value)["<< (*ip2_RowIndex)[i] <<"]["<< (*ip2_ColumnIndex)[i] <<"] ("<<(*dp3_Value)[(*ip2_RowIndex)[i]][j]<<")"<<endl;
		    fail_flag=true;
		    break;
		  }

		}

		return (fail_flag)?0:1;
	}
}
