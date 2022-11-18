/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "Definitions.h"

#ifdef SYSTEM_TIME

#include <sys/times.h>

#ifndef CLK_TCK
#define CLK_TCK 100
#endif

#else

#include <ctime>

#endif


#ifndef TIMER_H
#define TIMER_H

namespace ColPack
{
	/** @ingroup group4
	 *  @brief class Timer in @link group4@endlink.

	 The timer class is the only class in ColPack which has an optional dependency on the operating
	 system. It offers both system independent C++ timer based on ctime.h or linux/unix dependent timer based
	 on sys/times.h. The sytem independent timer only gives wall clock time while linux/unix dependent timer
	 gives wall, processor, user and system times.
	 */
	class Timer
	{
	  private:

/// UNIX only.  Used to measure longer execution time.
/** Define SYSTEM_TIME to measure the execution time of a program which may run for more than 30 minutes
(35.79 minutes or 2,147 seconds to be accurate)
Reason: In UNIX, CLOCKS_PER_SEC is defined to be 1,000,000 (In Windows, CLOCKS_PER_SEC == 1,000).
The # of clock-ticks is measured by using variables of type int => max value is 2,147,483,648.
Time in seconds = # of clock-ticks / CLOCKS_PER_SEC => max Time in seconds = 2,147,483,648 / 1,000,000 ~= 2,147
*/
#ifdef SYSTEM_TIME

		struct tms tms_BeginTimer;
		struct tms tms_EndTimer;
#endif

		clock_t ct_BeginTimer;
		clock_t ct_EndTimer;


	  public:

		//Public Constructor 4351
		Timer();

		//Public Destructor 4352
		~Timer();

		//Public Function 4354
		void Start();

		//Public Function 4355
		void Stop();

		//Public Function 4356
		double GetWallTime();

		//Public Function 4357
		double GetProcessorTime();

		//Public Function 4358
		double GetUserProcessorTime();

		//Public Function 4359
		double GetSystemProcessorTime();
	};
}
#endif
