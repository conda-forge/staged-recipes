/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#ifndef HESSIANRECOVERY_H
#define HESSIANRECOVERY_H

using namespace std;

namespace ColPack
{
	/** @ingroup group5
	 *  @brief class HessianRecovery in @link group5@endlink.
	 */
	class HessianRecovery : public RecoveryCore
	{
	public: //DOCUMENTED

		/// A routine for recovering a Hessian from a star-coloring based compressed representation.
		/**
		Parameter:
		- Input:
			- *g: GraphColoringInterface object, providing the coloring information
			- dp2_CompressedMatrix: The compressed matrix that contains all computed values
			- uip2_HessianSparsityPattern.
		- Output:
			- dp3_HessianValue

		Precondition:
		- Star coloring routine has been called.
		- uip2_HessianSparsityPattern: The Hessian matrix must be stored in compressed sparse rows format
		- dp3_HessianValue is just a pointer pointing to a 2D matrix (no memory allocated yet). This matrix will be created (memory will be allocated) by this routine and the pointer will be assigned to dp3_HessianValue

		Postcondition:
		- dp3_HessianValue points to a 2d matrix contains the numerical values of the Hessian. Row Compressed Format is used
		The memory allocated for this output vector is managed by ColPack. The memory will be deallocated when this function is called again or when the Recovery ojbect is deallocated.


		Return value: size of (*dp3_HessianValue) array

		About input parameters:
		- This routine doesn't need to take (star) coloring result m_vi_VertexColors of the Hessian as another paramenter because that information is known already (because of the 1st precondition). The cologin result can be retrieved from the first parameter "GraphColoringInterface* g"

		Row Compressed Format for dp3_HessianValue:
		- This is a 2D matrix of doubles.
		- The first element of each row will specify the number of non-zeros in the Hessian => Value of the first element + 1 will be the length of that row.
		- The value of each element after the 1st element is the value of the non-zero in the Hessian. The value of dp3_HessianValue[col][row] is the value of element [col][uip2_HessianSparsityPattern[col][row]] in the real (uncompressed) Hessian
		- An example of compressed sparse rows format:
			- Uncompressed matrix:	<br>
		1	.5	0	<br>
		.5	2	3	<br>
		0	3	-.5	<br>
			- Corresponding uip2_HessianSparsityPattern:	<br>
		2	0	1		<br>
		3	0	1	2	<br>
		2	1	2		<br>
			- Corresponding dp3_HessianValue:	<br>
		2	1	.5		<br>
		3	.5	2	3	<br>
		2	3	-.5		<br>

		Algorithm: optimized version of the algorithm in Figure 2, pg 8, "Efficient Computation of Sparse Hessians using Coloring and Automatic Differentiation" paper.
		The complexity of this routine is O(|E|) versus O(|E|*average distance-1 neighbour) for DirectRecover1
		- Do (column-)color statistic for each row, i.e., see how many elements in that row has color 0, color 1 ...
		Results are stored in map<int,int>* colorStatistic. colorStatistic[0] is (column-)color statistic for row 0
		If row 0 has 5 columns with color 3 => colorStatistic[0][3] = 5;
		- Allocate memory for *dp3_HessianValue
		- (Main part) Recover the values of non-zero entries in the Hessian:
		For each row, for each entry, see how many entries in that row have the same color by checking colorStatistic[row][column-color of the entry].
		If colorStatistic[#][#] == 1 => This entry has unique color (in this row). H[j,i] = B[j,color[hi]]
		else H[j,i] = B[i,color[hj]]
		Each non-zero value of the Hessian will be recovered from left to right, top to bottom
		Note: column-color of entry [row 5][column 3] is m_vi_VertexColors[column 3]
		*/
		int DirectRecover_RowCompressedFormat(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, double*** dp3_HessianValue);

		/// Same as DirectRecover_RowCompressedFormat(), except that the output is NOT managed by ColPack
		/** Notes:
		- The output is NOT managed by ColPack. Therefore, the user should free the output manually using free() (NOT delete) function when it is no longer needed.
		*/
		int DirectRecover_RowCompressedFormat_unmanaged(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, double*** dp3_HessianValue);

		/// Same as DirectRecover_RowCompressedFormat_unmanaged(), except that memory allocation for output vector(s) is done by user.
		/** Notes:
		- This function will assume the user has properly allocate memory output vector(s).
		No checking will be done so if you got a SEGMENTATION FAULT in this function, you should check and see if you have allocated memory properly for the output vector(s).
		(*dp3_HessianValue) should have the same structure as uip2_HessianSparsityPattern
		*/
		int DirectRecover_RowCompressedFormat_usermem(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, double*** dp3_HessianValue);


		/// A routine for recovering a Hessian from a star-coloring based compressed representation.
		/**
		Precondition:
		- (*uip2_RowIndex), (*uip2_ColumnIndex), and (*dp2_JacobianValue) are equal to NULL, i.e. no memory has been allocated for these 3 vectors yet

		Return value: size of (*uip2_RowIndex) array

		Return by recovery routine: three vectors in "Coordinate Format" (zero-based indexing)
		http://www.intel.com/software/products/mkl/docs/webhelp/appendices/mkl_appA_SMSF.html#mkl_appA_SMSF_5
		- unsigned int** uip2_RowIndex
		- unsigned int** uip2_ColumnIndex
		- double** dp2_JacobianValue // corresponding non-zero values
		NOTE: Since we are returning a symmetric matrix, only the upper triangle are stored.

		The memory allocated for these 3 output vectors are managed by ColPack.	The memory will be deallocated when this function is called again or when the Recovery ojbect is deallocated.
		//*/
		int DirectRecover_CoordinateFormat(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue);
//		int DirectRecover_CoordinateFormat_OMP(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue);

		/// Same as DirectRecover_CoordinateFormat(), except that the output is NOT managed by ColPack
		/** Notes:
		- The output is NOT managed by ColPack. Therefore, the user should free the output manually using free() (NOT delete) function when it is no longer needed.
		*/
		int DirectRecover_CoordinateFormat_unmanaged(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue);
//		int DirectRecover_CoordinateFormat_unmanaged_OMP(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue);

		/// Same as DirectRecover_CoordinateFormat_unmanaged(), except that memory allocation for output vector(s) is done by user. (OpenMP enabled)
		/** Notes:
		- This function will assume the user has properly allocate memory output vector(s).
		No checking will be done so if you got a SEGMENTATION FAULT in this function, you should check and see if you have allocated memory properly for the output vector(s).
		*/
//		int DirectRecover_CoordinateFormat_usermem_serial(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue);
		int DirectRecover_CoordinateFormat_usermem(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue);
		//int DirectRecover_CoordinateFormat_usermem_OMP(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue);


		/// A routine for recovering a Hessian from a star-coloring based compressed representation.
		/**
		Precondition:
		- (*uip2_RowIndex), (*uip2_ColumnIndex), and (*dp2_JacobianValue) are equal to NULL, i.e. no memory has been allocated for these 3 vectors yet

		Return value: size of (*uip2_RowIndex) array

		Return by recovery routine: three vectors in "Storage Formats for the Direct Sparse Solvers" (zero-based indexing)
		http://software.intel.com/sites/products/documentation/hpc/mkl/webhelp/appendices/mkl_appA_SMSF.html#mkl_appA_SMSF_1
		- unsigned int** uip2_RowIndex
		- unsigned int** uip2_ColumnIndex
		- double** dp2_JacobianValue // corresponding non-zero values
		NOTE: Since we are returning a symmetric matrix, according to format, only the upper triangle are stored.

		The memory allocated for these 3 output vectors are managed by ColPack.	The memory will be deallocated when this function is called again or when the Recovery ojbect is deallocated.
		*/
		int DirectRecover_SparseSolversFormat(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue);

		/// Same as DirectRecover_SparseSolversFormat(), except that the output is NOT managed by ColPack
		/**
		About input parameters:
		- numOfNonZerosInHessianValue: the size of (*uip2_ColumnIndex) and (*dp2_HessianValue) arrays.
		The value of numOfNonZerosInHessianValue will be calculated if not provided (i.e. <1).

		Notes:
		- The output is NOT managed by ColPack. Therefore, the user should free the output manually using free() (NOT delete) function when it is no longer needed.
		*/
		int DirectRecover_SparseSolversFormat_unmanaged(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue, unsigned int numOfNonZerosInHessianValue = 0);

		/// Same as DirectRecover_SparseSolversFormat_unmanaged(), except that memory allocation for output vector(s) is done by user.
		/**
		About input parameters:
		- numOfNonZerosInHessianValue: the size of (*uip2_ColumnIndex) and (*dp2_HessianValue) arrays.

		Notes:
		- This function will assume the user has properly allocate memory output vector(s).
		No checking will be done so if you got a SEGMENTATION FAULT in this function, you should check and see if you have allocated memory properly for the output vector(s).
		*/
		int DirectRecover_SparseSolversFormat_usermem(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue, unsigned int numOfNonZerosInHessianValue);


		/// A routine for recovering a Hessian from a acyclic-coloring based compressed representation.
		/**
		Parameter:
		- Input:
			- *g: GraphColoringInterface object, providing the coloring information
			- dp2_CompressedMatrix: The compressed matrix that contains all computed values
			- uip2_HessianSparsityPattern.
		- Output:
			- dp3_HessianValue

		Precondition:
		- Acyclic coloring routine has been called.
		- uip2_HessianSparsityPattern: The Hessian matrix must be stored in compressed sparse rows format
		- dp3_HessianValue is just a pointer pointing to a 2D matrix (no memory allocated yet). This matrix will be created (memory will be allocated) by IndirectRecover2() and the pointer will be assigned to dp3_HessianValue

		Postcondition:
		- dp3_HessianValue points to a 2d matrix contains the numerical values of the Hessian. Row Compressed Format is used
		The memory allocated for this output vector is managed by ColPack. The memory will be deallocated when this function is called again or when the Recovery ojbect is deallocated.

		Return value: size of (*dp3_HessianValue) array

		About input parameters:
		- This routine doesn't need to take (acyclic) coloring result m_vi_VertexColors of the Hessian as another paramenter because that information is known already (because of the 1st precondition).

		Row Compressed Format for dp3_HessianValue: see DirectRecover2()

		Algorithm: created by Assefaw, 1st implemented by Arijit Tarafdar. This function is just a modification of Arijit's implementation
		*/
		int IndirectRecover_RowCompressedFormat(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, double*** dp3_HessianValue);

		/// Same as IndirectRecover_RowCompressedFormat(), except that the output is NOT managed by ColPack
		/** Notes:
		- The output is NOT managed by ColPack. Therefore, the user should free the output manually using free() (NOT delete) function when it is no longer needed.
		*/
		int IndirectRecover_RowCompressedFormat_unmanaged(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, double*** dp3_HessianValue);

		/// Same as IndirectRecover_RowCompressedFormat_unmanaged(), except that memory allocation for output vector(s) is done by user.
		/** Notes:
		- This function will assume the user has properly allocate memory output vector(s).
		No checking will be done so if you got a SEGMENTATION FAULT in this function, you should check and see if you have allocated memory properly for the output vector(s).
		*/
		int IndirectRecover_RowCompressedFormat_usermem(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, double*** dp3_HessianValue);


		/// A routine for recovering a Hessian from a acyclic-coloring based compressed representation.
		/**
		Precondition:
		- (*uip2_RowIndex), (*uip2_ColumnIndex), and (*dp2_JacobianValue) are equal to NULL, i.e. no memory has been allocated for these 3 vectors yet

		Return value: size of (*uip2_RowIndex) array

		Return by recovery routine: three vectors in "Coordinate Format" (zero-based indexing)
		http://www.intel.com/software/products/mkl/docs/webhelp/appendices/mkl_appA_SMSF.html#mkl_appA_SMSF_5
		- unsigned int** uip2_RowIndex
		- unsigned int** uip2_ColumnIndex
		- double** dp2_JacobianValue // corresponding non-zero values
		NOTE: Since we are returning a symmetric matrix, only the upper triangle are stored.

		The memory allocated for these 3 output vectors are managed by ColPack.	The memory will be deallocated when this function is called again or when the Recovery ojbect is deallocated.
		//*/
		int IndirectRecover_CoordinateFormat(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue);

		/// Same as IndirectRecover_CoordinateFormat(), except that the output is NOT managed by ColPack
		/** Notes:
		- The output is NOT managed by ColPack. Therefore, the user should free the output manually using free() (NOT delete) function when it is no longer needed.
		*/
		int IndirectRecover_CoordinateFormat_unmanaged(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue);

		/// Same as IndirectRecover_CoordinateFormat_unmanaged(), except that memory allocation for output vector(s) is done by user.
		/** Notes:
		- This function will assume the user has properly allocate memory output vector(s).
		No checking will be done so if you got a SEGMENTATION FAULT in this function, you should check and see if you have allocated memory properly for the output vector(s).
		*/
		int IndirectRecover_CoordinateFormat_usermem(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue);


		/// A routine for recovering a Hessian from a acyclic-coloring based compressed representation.
		/**
		Precondition:
		- (*uip2_RowIndex), (*uip2_ColumnIndex), and (*dp2_JacobianValue) are equal to NULL, i.e. no memory has been allocated for these 3 vectors yet

		Return value: size of (*uip2_RowIndex) array

		Return by recovery routine: three vectors in "Storage Formats for the Direct Sparse Solvers" (zero-based indexing)
		http://software.intel.com/sites/products/documentation/hpc/mkl/webhelp/appendices/mkl_appA_SMSF.html#mkl_appA_SMSF_1
		- unsigned int** uip2_RowIndex
		- unsigned int** uip2_ColumnIndex
		- double** dp2_JacobianValue // corresponding non-zero values
		NOTE: Since we are returning a symmetric matrix, according to format, only the upper triangle are stored.

		The memory allocated for these 3 output vectors are managed by ColPack.	The memory will be deallocated when this function is called again or when the Recovery ojbect is deallocated.
		*/
		int IndirectRecover_SparseSolversFormat(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue);

		/// Same as IndirectRecover_SparseSolversFormat(), except that the output is NOT managed by ColPack
		/**
		About input parameters:
		- numOfNonZerosInHessianValue: the size of (*uip2_ColumnIndex) and (*dp2_HessianValue) arrays.
		The value of numOfNonZerosInHessianValue will be calculated if not provided (i.e. <1).

		Notes:
		- The output is NOT managed by ColPack. Therefore, the user should free the output manually using free() (NOT delete) function when it is no longer needed.
		*/
		int IndirectRecover_SparseSolversFormat_unmanaged(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue, unsigned int numOfNonZerosInHessianValue = 0);

		/// Same as IndirectRecover_SparseSolversFormat_unmanaged(), except that memory allocation for output vector(s) is done by user.
		/**
		About input parameters:
		- numOfNonZerosInHessianValue: the size of (*uip2_ColumnIndex) and (*dp2_HessianValue) arrays.

		Notes:
		- This function will assume the user has properly allocate memory output vector(s).
		No checking will be done so if you got a SEGMENTATION FAULT in this function, you should check and see if you have allocated memory properly for the output vector(s).
		*/
		int IndirectRecover_SparseSolversFormat_usermem(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, unsigned int** uip2_RowIndex, unsigned int** uip2_ColumnIndex, double** dp2_HessianValue, unsigned int numOfNonZerosInHessianValue);

	  private:
		int DirectRecover_CoordinateFormat_vectors(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, vector<unsigned int> &RowIndex, vector<unsigned int> &ColumnIndex, vector<double> &HessianValue);
//		int DirectRecover_CoordinateFormat_vectors_OMP(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, vector<unsigned int> &RowIndex, vector<unsigned int> &ColumnIndex, vector<double> &HessianValue);
		int IndirectRecover_CoordinateFormat_vectors(GraphColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_HessianSparsityPattern, vector<unsigned int> &RowIndex, vector<unsigned int> &ColumnIndex, vector<double> &HessianValue);
	};
}
#endif
