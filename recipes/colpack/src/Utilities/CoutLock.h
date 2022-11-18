/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#ifndef COUTLOCK_H
#define COUTLOCK_H

#ifdef _OPENMP
	#include <omp.h>
#endif

namespace ColPack
{
	/** @ingroup group4
	 *  @brief class CoutLock in @link group4@endlink.

	 The CoutLock class is used in a multi-thread environment to support printing strings to standard output in a readable manner.
	 Here is how you do cout:
	 CoutLock::set(); cout<<"blah blah blah"<<int<<endl;CoutLock::unset();
	 */

	class CoutLock
	{
	public:
#ifdef _OPENMP
		static omp_lock_t coutLock;
#endif

		static int set();
		static int unset();
	};
}
#endif
