/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#ifndef JACOBIANRECOVERY2D_H
#define JACOBIANRECOVERY2D_H

using namespace std;

namespace ColPack
{
	/** @ingroup group5
	 *  @brief class JacobianRecovery2D in @link group5@endlink.
	 */
	class JacobianRecovery2D : public RecoveryCore
	{
	public: //DOCUMENTED

		/// A routine for recovering a Jacobian from a Star-Bicoloring based compressed representation.
		/**
		Parameter:
		- Input:
			- dp2_RowCompressedMatrix: The row compressed matrix that contains all computed values. Row compressed matrix is the matrix where all rows with the same color ID (the values of m_vi_LeftVertexColors[] are equal) are merged together.
			- dp2_ColumnCompressedMatrix: The column compressed matrix that contains all computed values. Column compressed matrix is the matrix where all columns with the same color ID (the values of m_vi_RightVertexColors[] are equal) are merged together.
			- uip2_JacobianSparsityPattern.
		- Output:
			- dp3_JacobianValue

		Precondition:
		- Star Bicoloring routine has been called.
		- uip2_JacobianSparsityPattern: The Jacobian matrix must be stored in compressed sparse rows format
		- dp3_JacobianValue is just a pointer pointing to a 2D matrix (no memory allocated yet). This matrix will be created (memory will be allocated) by DirectRecover() and the pointer will be assigned to dp3_JacobianValue

		Postcondition:
		- dp3_JacobianValue points to a 2d matrix contains the numerical values of the Jacobian. Row Compressed Format is used.
		The memory allocated for this output vector is managed by ColPack. The memory will be deallocated when this function is called again or when the Recovery ojbect is deallocated.

		Return value: size of (*dp3_JacobianValue) array

		About input parameters:
		- This routine doesn't need to take (Star) Bicoloring results (m_vi_LeftVertexColors and m_vi_RightVertexColors) of the Jacobian as another paramenter because that information is known internally already (because of the 1st precondition).

		Row Compressed Format for dp3_JacobianValue:
		- This is a 2D matrix of doubles.
		- The first element of each row will specify the number of non-zeros in the Jacobian => Value of the first element + 1 will be the length of that row.
		- The value of each element after the 1st element is the value of the non-zero in the Jacobian. The value of dp3_JacobianValue[col][row] is the value of element [col][uip2_JacobianSparsityPattern[col][row]] in the real (uncompressed) Jacobian
		- An example of compressed sparse rows format:
			- Uncompressed matrix:	<br>
		1	.5	0	<br>
		.2	2	3	<br>
		0	6	-.5	<br>
			- Corresponding uip2_JacobianSparsityPattern:	<br>
		2	0	1		<br>
		3	0	1	2	<br>
		2	1	2		<br>
			- Corresponding dp3_JacobianValue:	<br>
		2	1	.5		<br>
		3	.2	2	3	<br>
		2	6	-.5		<br>

		Algorithm: Basically the combination of RecoverForPD2RowWise() (for dp2_RowCompressedMatrix) and RecoverForPD2ColumnWise() (for dp2_ColumnCompressedMatrix) in BipartiteGraphPartialColoringInterface class
		*/
		int DirectRecover_RowCompressedFormat(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue);

		/// Same as DirectRecover_RowCompressedFormat(), except that the output is NOT managed by ColPack
		/** Notes:
		- The output is NOT managed by ColPack. Therefore, the user should free the output manually using free() (NOT delete) function when it is no longer needed.
		*/
		int DirectRecover_RowCompressedFormat_unmanaged(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue);

		/// Same as DirectRecover_RowCompressedFormat_unmanaged(), except that memory allocation for output vector(s) is done by user.
		/** Notes:
		- This function will assume the user has properly allocate memory output vector(s).
		No checking will be done so if you got a SEGMENTATION FAULT in this function, you should check and see if you have allocated memory properly for the output vector(s).
		(*dp3_JacobianValue) should have the same structure as uip2_JacobianSparsityPattern
		*/
		int DirectRecover_RowCompressedFormat_usermem(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue);


		/// A routine for recovering a Jacobian from a Star-Bicoloring based compressed representation.
		/**
		Precondition:
		- (*ip2_RowIndex), (*ip2_ColumnIndex), and (*dp2_JacobianValue) are equal to NULL, i.e. no memory has been allocated for these 3 vectors yet

		Return value: size of (*ip2_RowIndex) array

		Return by recovery routine: three vectors in "Coordinate Format" (zero-based indexing)
		http://www.intel.com/software/products/mkl/docs/webhelp/appendices/mkl_appA_SMSF.html#mkl_appA_SMSF_5
		- unsigned int** ip2_RowIndex
		- unsigned int** ip2_ColumnIndex
		- double** dp2_JacobianValue // corresponding non-zero values

		The memory allocated for these 3 output vectors are managed by ColPack.	The memory will be deallocated when this function is called again or when the Recovery ojbect is deallocated.
		//*/
		int DirectRecover_CoordinateFormat(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);

		/// Same as DirectRecover_CoordinateFormat(), except that the output is NOT managed by ColPack
		/** Notes:
		- The output is NOT managed by ColPack. Therefore, the user should free the output manually using free() (NOT delete) function when it is no longer needed.
		*/
		int DirectRecover_CoordinateFormat_unmanaged(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);

		/// Same as DirectRecover_CoordinateFormat_unmanaged(), except that memory allocation for output vector(s) is done by user.
		/** Notes:
		- This function will assume the user has properly allocate memory output vector(s).
		No checking will be done so if you got a SEGMENTATION FAULT in this function, you should check and see if you have allocated memory properly for the output vector(s).
		*/
		int DirectRecover_CoordinateFormat_usermem(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);


		/// A routine for recovering a Jacobian from a Star-Bicoloring based compressed representation.
		/**
		Precondition:
		- (*ip2_RowIndex), (*ip2_ColumnIndex), and (*dp2_JacobianValue) are equal to NULL, i.e. no memory has been allocated for these 3 vectors yet

		Return value: size of (*ip2_RowIndex) array

		Return by recovery routine: three vectors in "Storage Formats for the Direct Sparse Solvers" (one-based indexing)
		http://software.intel.com/sites/products/documentation/hpc/mkl/webhelp/appendices/mkl_appA_SMSF.html#mkl_appA_SMSF_1
		- unsigned int** ip2_RowIndex
		- unsigned int** ip2_ColumnIndex
		- double** dp2_JacobianValue // corresponding non-zero values
		Note: In case of Jacobian (non-symmetric matrix), Sparse Solvers Format is equivalent to
		one-based indexing, 3 array variation CSR format
		http://software.intel.com/sites/products/documentation/hpc/mkl/webhelp/appendices/mkl_appA_SMSF.html#table_79228E147DA0413086BEFF4EFA0D3F04

		The memory allocated for these 3 output vectors are managed by ColPack.	The memory will be deallocated when this function is called again or when the Recovery ojbect is deallocated.
		//*/
		int DirectRecover_SparseSolversFormat(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);

		/// Same as DirectRecover_SparseSolversFormat(), except that the output is NOT managed by ColPack
		/** Notes:
		- The output is NOT managed by ColPack. Therefore, the user should free the output manually using free() (NOT delete) function when it is no longer needed.
		*/
		int DirectRecover_SparseSolversFormat_unmanaged(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);

		/// Same as DirectRecover_SparseSolversFormat_unmanaged(), except that memory allocation for output vector(s) is done by user.
		/** Notes:
		- This function will assume the user has properly allocate memory output vector(s).
		No checking will be done so if you got a SEGMENTATION FAULT in this function, you should check and see if you have allocated memory properly for the output vector(s).
		*/
		int DirectRecover_SparseSolversFormat_usermem(BipartiteGraphBicoloringInterface* g, double** dp2_RowCompressedMatrix, double** dp2_ColumnCompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);

	};
}
#endif

