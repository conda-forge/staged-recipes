/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#ifndef JACOBIANRECOVERY1D_H
#define JACOBIANRECOVERY1D_H

using namespace std;

namespace ColPack
{
	/** @ingroup group5
	 *  @brief class JacobianRecovery1D in @link group5@endlink.
	 */
	class JacobianRecovery1D : public RecoveryCore
	{
	public: //DOCUMENTED

		/// A routine for recovering a Jacobian from a "Row-wise Distance 2 coloring"-based compressed representation.
		/**
		Return by recovery routine: double*** dp3_JacobianValue

		Precondition:
		- Row-wise Distance 2 coloring routine has been called.
		- uip2_JacobianSparsityPattern (input) The Jacobian matrix must be stored in compressed sparse rows format
		- dp3_JacobianValue (output) is just a pointer pointing to a 2D matrix (no memory allocated yet). This matrix will be created (memory will be allocated) by DirectRecover() and the pointer will be assigned to dp3_JacobianValue

		Postcondition:
		- dp3_JacobianValue points to a 2d matrix contains the numerical values of the Jacobian. Row Compressed Format is used
		The memory allocated for this output vector is managed by ColPack. The memory will be deallocated when this function is called again or when the Recovery ojbect is deallocated.

		Return value: size of (*dp3_JacobianValue) array

		About input parameters:
		- This routine doesn't take (Row-wise Distance 2) coloring result m_vi_LeftVertexColors of the Jacobian as another paramenter because that information is known already (because of the 1st precondition).

		Row Compressed Format for dp3_JacobianValue:
		- This is a 2D matrix of doubles.
		- The first element of each row will specify the number of non-zeros in the Jacobian => Value of the first element + 1 will be the length of that row.
		- The value of each element after the 1st element is the value of the non-zero in the Jacobian. The value of dp3_JacobianValue[col][row] is the value of element [col][uip2_JacobianSparsityPattern[col][row]] in the real (uncompressed) Jacobian

		An example of compressed sparse rows format:
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
		*/
		int RecoverD2Row_RowCompressedFormat(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue);

		/// Same as RecoverD2Row_RowCompressedFormat(), except that the output is NOT managed by ColPack
		/** Notes:
		- The output is NOT managed by ColPack. Therefore, the user should free the output manually using free() (NOT delete) function when it is no longer needed.
		*/
		int RecoverD2Row_RowCompressedFormat_unmanaged(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue);

		/// Same as RecoverD2Row_RowCompressedFormat_unmanaged(), except that memory allocation for output vector(s) is done by user.
		/** Notes:
		- This function will assume the user has properly allocate memory output vector(s).
		No checking will be done so if you got a SEGMENTATION FAULT in this function, you should check and see if you have allocated memory properly for the output vector(s).
		(*dp3_JacobianValue) should have the same structure as uip2_JacobianSparsityPattern
		*/
		int RecoverD2Row_RowCompressedFormat_usermem(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue);


		/// A routine for recovering a Jacobian from a "Row-wise Distance 2 coloring"-based compressed representation.
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
		int RecoverD2Row_SparseSolversFormat(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);

		/// Same as RecoverD2Row_SparseSolversFormat(), except that the output is NOT managed by ColPack
		/** Notes:
		- The output is NOT managed by ColPack. Therefore, the user should free the output manually using free() (NOT delete) function when it is no longer needed.
		*/
		int RecoverD2Row_SparseSolversFormat_unmanaged(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);

		/// Same as RecoverD2Row_SparseSolversFormat_usermem(), except that memory allocation for output vector(s) is done by user.
		/** Notes:
		- This function will assume the user has properly allocate memory output vector(s).
		No checking will be done so if you got a SEGMENTATION FAULT in this function, you should check and see if you have allocated memory properly for the output vector(s).
		*/
		int RecoverD2Row_SparseSolversFormat_usermem(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);


		/// A routine for recovering a Jacobian from a "Row-wise Distance 2 coloring"-based compressed representation.
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
		*/
		int RecoverD2Row_CoordinateFormat(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);
//		int RecoverD2Row_CoordinateFormat_OMP(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);

		/// Same as RecoverD2Row_CoordinateFormat(), except that the output is NOT managed by ColPack
		/** Notes:
		- The output is NOT managed by ColPack. Therefore, the user should free the output manually using free() (NOT delete) function when it is no longer needed.
		*/
		int RecoverD2Row_CoordinateFormat_unmanaged(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);
//		int RecoverD2Row_CoordinateFormat_unmanaged_OMP(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);

		/// Same as RecoverD2Row_CoordinateFormat_unmanaged(), except that memory allocation for output vector(s) is done by user. (OpenMP enabled)
		/** Notes:
		- This function will assume the user has properly allocate memory output vector(s).
		No checking will be done so if you got a SEGMENTATION FAULT in this function, you should check and see if you have allocated memory properly for the output vector(s).
		*/
//		int RecoverD2Row_CoordinateFormat_usermem_serial(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);
		int RecoverD2Row_CoordinateFormat_usermem(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);
		//int RecoverD2Row_CoordinateFormat_usermem_OMP(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);


		/// A routine for recovering a Jacobian from a "Column-wise Distance 2 coloring"-based compressed representation.
		/**
		Return by recovery routine: double*** dp3_JacobianValue

		Precondition:
		- Column-wise Distance 2 coloring routine has been called.
		- uip2_JacobianSparsityPattern (input) The Jacobian matrix must be stored in compressed sparse rows format
		- dp3_JacobianValue (output) is just a pointer pointing to a 2D matrix (no memory allocated yet). This matrix will be created (memory will be allocated) by DirectRecover() and the pointer will be assigned to dp3_JacobianValue

		Postcondition:
		- dp3_JacobianValue points to a 2d matrix contains the numerical values of the Jacobian. Row Compressed Format is used
		The memory allocated for this output vector is managed by ColPack. The memory will be deallocated when this function is called again or when the Recovery ojbect is deallocated.

		Return value: size of (*dp3_JacobianValue) array

		About input parameters:
		- This routine doesn't take (Column-wise Distance 2) coloring result m_vi_RightVertexColors of the Jacobian as another paramenter because that information is known already (because of the 1st precondition).

		Row Compressed Format for dp3_JacobianValue:
		- This is a 2D matrix of doubles.
		- The first element of each row will specify the number of non-zeros in the Jacobian => Value of the first element + 1 will be the length of that row.
		- The value of each element after the 1st element is the value of the non-zero in the Jacobian. The value of dp3_JacobianValue[col][row] is the value of element [col][uip2_JacobianSparsityPattern[col][row]] in the real (uncompressed) Jacobian

		An example of compressed sparse rows format:
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
		*/
		int RecoverD2Cln_RowCompressedFormat(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue);

		int RecoverD2Cln_ADICFormat(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, std::list<std::set<int> >& lsi_SparsityPattern, std::list<std::vector<double> > &lvd_NewValue);

		/// Same as RecoverD2Cln_RowCompressedFormat(), except that the output is NOT managed by ColPack
		/** Notes:
		- The output is NOT managed by ColPack. Therefore, the user should free the output manually using free() (NOT delete) function when it is no longer needed.
		*/
		int RecoverD2Cln_RowCompressedFormat_unmanaged(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue);

		/// Same as RecoverD2Cln_RowCompressedFormat_unmanaged(), except that memory allocation for output vector(s) is done by user.
		/** Notes:
		- This function will assume the user has properly allocate memory output vector(s).
		No checking will be done so if you got a SEGMENTATION FAULT in this function, you should check and see if you have allocated memory properly for the output vector(s).
		(*dp3_JacobianValue) should have the same structure as uip2_JacobianSparsityPattern
		*/
		int RecoverD2Cln_RowCompressedFormat_usermem(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, double*** dp3_JacobianValue);


		/// A routine for recovering a Jacobian from a "Column-wise Distance 2 coloring"-based compressed representation.
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
		int RecoverD2Cln_SparseSolversFormat(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);

		/// Same as RecoverD2Cln_SparseSolversFormat(), except that the output is NOT managed by ColPack
		/** Notes:
		- The output is NOT managed by ColPack. Therefore, the user should free the output manually using free() (NOT delete) function when it is no longer needed.
		*/
		int RecoverD2Cln_SparseSolversFormat_unmanaged(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);

		/// Same as RecoverD2Cln_SparseSolversFormat_unmanaged(), except that memory allocation for output vector(s) is done by user.
		/** Notes:
		- This function will assume the user has properly allocate memory output vector(s).
		No checking will be done so if you got a SEGMENTATION FAULT in this function, you should check and see if you have allocated memory properly for the output vector(s).
		*/
		int RecoverD2Cln_SparseSolversFormat_usermem(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);


		/// A routine for recovering a Jacobian from a "Column-wise Distance 2 coloring"-based compressed representation.
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
		int RecoverD2Cln_CoordinateFormat(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);
//		int RecoverD2Cln_CoordinateFormat_OMP(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);

		/// Same as RecoverD2Cln_CoordinateFormat(), except that the output is NOT managed by ColPack
		/** Notes:
		- The output is NOT managed by ColPack. Therefore, the user should free the output manually using free() (NOT delete) function when it is no longer needed.
		*/
		int RecoverD2Cln_CoordinateFormat_unmanaged(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);
//		int RecoverD2Cln_CoordinateFormat_unmanaged_OMP(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);

		/// Same as RecoverD2Cln_CoordinateFormat_unmanaged(), except that memory allocation for output vector(s) is done by user. (OpenMP enabled)
		/** Notes:
		- This function will assume the user has properly allocate memory output vector(s).
		No checking will be done so if you got a SEGMENTATION FAULT in this function, you should check and see if you have allocated memory properly for the output vector(s).
		*/
//		int RecoverD2Cln_CoordinateFormat_usermem_serial(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);
		int RecoverD2Cln_CoordinateFormat_usermem(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);
		//int RecoverD2Cln_CoordinateFormat_usermem_OMP(BipartiteGraphPartialColoringInterface* g, double** dp2_CompressedMatrix, unsigned int ** uip2_JacobianSparsityPattern, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue);

		// Compare 2 matrices in Coordinate Format. Return 1 if they are the same, return 0 if they are different
		int CompareMatrix_CoordinateFormat_vs_CoordinateFormat(int i_rowCount, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue, unsigned int** ip2_RowIndex2, unsigned int** ip2_ColumnIndex2, double** dp2_JacobianValue2);

		// Compare 2 matrices (the first one in Coordinate Format and the second one in Row Compressed Format). Return 1 if they are the same, return 0 if they are different
		// !!! not tested
		int CompareMatrix_CoordinateFormat_vs_RowCompressedFormat(int i_rowCount, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex, double** dp2_JacobianValue, int rowCount2, unsigned int *** uip3_SparsityPattern, double*** dp3_Value);
	};
}
#endif

