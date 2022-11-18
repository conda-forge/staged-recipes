/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "Definitions.h"

#ifndef MATRIXDEALLOCATION_H
#define MATRIXDEALLOCATION_H

/// Deallocate all the memory reserved for a matrix presented in Sparse Solvers Format
/**  Postcondition:
    - ip2_RowIndex, ip2_ColumnIndex, dp2_JacobianValue become dangling pointers. So for safety reasons, please set ip2_RowIndex, ip2_ColumnIndex, dp2_JacobianValue to NULL after calling this function.
*/
int MatrixDeallocation_SparseSolversFormat(unsigned int **ip2_RowIndex, unsigned int **ip2_ColumnIndex, double **dp2_JacobianValue);

/// Deallocate all the memory reserved for a matrix presented in ADOLC Format
/** Postcondition:
    - dp3_HessianValue become dangling pointers. So for safety reasons, please set dp3_HessianValue to NULL after calling this function.
*/
int MatrixDeallocation_RowCompressedFormat(double ***dp3_HessianValue, unsigned int i_numOfRows);

/** Deallocate all the memory reserved for a matrix presented in Coordinate Format
    Postcondition:
    - ip2_RowIndex, ip2_ColumnIndex, dp2_HessianValue become dangling pointers. So for safety reasons, please set ip2_RowIndex, ip2_ColumnIndex, dp2_HessianValue to NULL after calling this function.
*/
int MatrixDeallocation_CoordinateFormat(unsigned int **ip2_RowIndex, unsigned int **ip2_ColumnIndex, double **dp2_HessianValue);


template<typename T>
int free_2DMatrix(T **dp2_2DMatrix, unsigned int i_numOfRows) {
  for(unsigned int i=0; i< i_numOfRows; i++) {
    delete[] (dp2_2DMatrix)[i];
  }
  delete[] (dp2_2DMatrix);

  return _TRUE;
}

template<typename T>
int free_2DMatrix(T ***dp3_2DMatrix, unsigned int i_numOfRows) {
	free_2DMatrix(*dp3_2DMatrix,i_numOfRows);
	delete dp3_2DMatrix;

  return _TRUE;
}

#endif
