/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "MatrixDeallocation.h"

int MatrixDeallocation_SparseSolversFormat(unsigned int **ip2_RowIndex, unsigned int **ip2_ColumnIndex, double **dp2_JacobianValue) {
  //Deallocate the arrays
  delete[] (*ip2_RowIndex);
  delete ip2_RowIndex;

  delete[] (*ip2_ColumnIndex);
  delete ip2_ColumnIndex;

  delete[] (*dp2_JacobianValue);
  delete dp2_JacobianValue;

  return _TRUE;
}

int MatrixDeallocation_RowCompressedFormat(double ***dp3_HessianValue, unsigned int i_numOfRows) {
  //Deallocate the 2D Matrix
	free_2DMatrix(dp3_HessianValue, i_numOfRows);
	return _TRUE;
}


int MatrixDeallocation_CoordinateFormat(unsigned int **ip2_RowIndex, unsigned int **ip2_ColumnIndex, double **dp2_HessianValue) {
  //Deallocate the arrays
  delete[] (*ip2_RowIndex);
  delete ip2_RowIndex;

  delete[] (*ip2_ColumnIndex);
  delete ip2_ColumnIndex;

  delete[] (*dp2_HessianValue);
  delete dp2_HessianValue;

  return _TRUE;
}

