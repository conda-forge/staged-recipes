/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#ifndef RECOVERYCORE_H
#define RECOVERYCORE_H

using namespace std;

namespace ColPack
{
	/** @ingroup group5
	 *  @brief class RecoveryCore in @link group5@endlink.
	 *
	 * This class  will keep track of all the memories allocated and
	 * its destructor will be responsible to destroy the memory allocated for
	 * arrays/matrices of all the Recovery classes.
	 *
	 * This class currently supports matrices in one of the following three formats:
	 * RowCompressedFormat (AF), CoordinateFormat (CF), and SparseSolversFormat (SSF)
	 *
	 * For one graph, you can call the Recovery routine once for each format.
	 * Calling the same recovery function twice will make this class reset() (see the example below):
	 *
	 * Matrix in a particular format is generated when the Recovery routine of the corresponding format is called.
	 * For example, here is one possible sequence:
	 * 		JacobianRecovery1D jr1d; // create an oject of subclass of RecoveryCore
	 * 		jr1d.RecoverD2Row_RowCompressedFormat(graph1 , ...); // output matrix in ADOLC Format is generated
	 * 		jr1d.RecoverD2Row_SparseSolversFormat(graph1 , ...); // output matrix in Sparse Solvers Format is generated
	 * 		jr1d.RecoverD2Row_CoordinateFormat(graph1 , ...); // output matrix in Coordinate Format is generated
	 *
	 * 		// Matrices in all 3 formats will be deallocated, a new output matrix in Coordinate Format is generated
	 * 		// Here, because the user call RecoverD2Row_CoordinateFormat() for the second time,
	 * 		// we assume that the user have a new graph, so clean up old matrices is necessary.
	 * 		// Note: DO NOT call the same recovery function twice unless you have a new graph!!!
	 * 		jr1d.RecoverD2Row_CoordinateFormat(graph2 , ...);
	 */
	class  RecoveryCore
	{
	public: // !!!NEED DOCUMENT
		RecoveryCore();
		~RecoveryCore();
	protected:
		//string formatType; //At this point, could be either: "RowCompressedFormat," "CoordinateFormat," or "SparseSolversFormat"

		//for ADOL-C Format (AF)
		bool AF_available;
		int i_AF_rowCount;
		double** dp2_AF_Value;

		//for Sparse Solvers Format (SSF)
		bool SSF_available;
		int i_SSF_rowCount;
		unsigned int* ip_SSF_RowIndex;
		unsigned int* ip_SSF_ColumnIndex;
		double* dp_SSF_Value;

		//for Coordinate Format (CF)
		bool CF_available;
		int i_CF_rowCount;
		unsigned int* ip_CF_RowIndex;
		unsigned int* ip_CF_ColumnIndex;
		double* dp_CF_Value;

		void reset();
	};
}

#endif
