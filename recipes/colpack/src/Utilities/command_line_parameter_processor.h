/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include<iostream>
#include<string>
#include<vector>

using namespace std;

/*Convert command line parameters to vector arg for easiness
Input: argc, argv
Output: arg
Precondition: arg is empty
*/
void createArgs(int argc, const char* argv[], vector<string>& arg);

//find argument in vector arg
int findArg(string argument, vector<string>& arg);

//SAMPLE main.cpp
/*
#include "command_line_parameter_processor.h"

using namespace std;

int commandLineProcessing(vector<string>& arg);

int main(int argc, const char* argv[] ) {
	vector<string> arg;

	//get the list of arguments
	createArgs(argc, argv, arg);

	//process those arguments
	commandLineProcessing(arg);

	//...

	return 0;
}

int commandLineProcessing(vector<string>& arg) {

	int num=findArg("-r", arg);
	if (num!=-1) //argument is found, do something
	{
		//...
	}

	if (findArg("-append", arg) != -1 || findArg("-app", arg) != -1) //append output to the existing file
	{
		output_append = true;
	}

	//"-suffix" has priority over "-suf", i.e., if both "-suffix" and "-suf" are specified, "-suffix <output_suffix>" will be used
	int result;
	result = findArg("-suffix", arg);
	if (result == -1) result = findArg("-suf", arg);
	if (result != -1) //suffix is specified
	{
		output_suffix = arg[result+1];
	}

	return 0;
}
//*/


