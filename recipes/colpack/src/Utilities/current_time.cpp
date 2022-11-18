/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include <iostream>
#include <ctime>

using namespace std;

#include "current_time.h"

void current_time() {
  time_t curr=time(0);
  cout << "Current time is: " << ctime(&curr) <<endl;
}
