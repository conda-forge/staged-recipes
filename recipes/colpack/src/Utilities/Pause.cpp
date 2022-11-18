/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

//Special pause that work on both Windows and UNIX for both C and C++
#include "Pause.h"

using namespace std;

void Pause()
{
		printf("Press enter to continue ...");
		getchar();
}
