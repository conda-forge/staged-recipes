/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include <string>

#include "Definitions.h"

#include "File.h"

using namespace std;

namespace ColPack
{
	File::File()
	{
		path = "";
		name = "";
		fileExtension = "";
	}

	File::File(string fileName)
	{
		path = "";
		name = "";
		fileExtension = "";
		Parse(fileName);
	}

	string File::GetPath() const {return path;}

	string File::GetName() const {return name;}

	string File::GetFileExtension() const {return fileExtension;}

	string File::GetFullName() const {return name+"."+fileExtension;}

	void File::SetPath(string newPath) {path = newPath;}

	void File::SetName(string newName) {name = newName;}

	void File::SetFileExtension(string newFileExtension) {fileExtension = newFileExtension;}

	void File::Parse(string fileName) {
		string::size_type result;

		//1. see if the fileName is given in full path
		result = fileName.rfind(DIR_SEPARATOR, fileName.size() - 1);
		if(result != string::npos) {//found the path (file prefix)
			//get the path, including the last DIR_SEPARATOR
			path = fileName.substr(0,result+1);
			//remove the path from the fileName
			fileName = fileName.substr(result+1);
		}

		//2. see if the fileName has file extension. For example ".mtx"
		result = fileName.rfind('.', fileName.size() - 1);
		if(result != string::npos) {//found the fileExtension
			//get the fileExtension excluding the '.'
			fileExtension = fileName.substr(result+1);
			//remove the fileExtension from the fileName
			fileName = fileName.substr(0,result);
		}

		//3. get the name of the input file
		name = fileName;
	}

	bool isMatrixMarketFormat(string s_fileExtension) {
		if (s_fileExtension == "mtx")
			return true;
		return false;
	}

	bool isHarwellBoeingFormat(string s_fileExtension){
		if (s_fileExtension == "hb" || (
				s_fileExtension.size()==3 && (
					// First Character of the Extension
					s_fileExtension[0] == 'r' ||	// Real matrix
					s_fileExtension[0] == 'c' ||	// Complex matrix
					s_fileExtension[0] == 'p'		// Pattern only (no numerical values supplied)
				) && (
					// Second Character of the Extension
					s_fileExtension[1] == 's' ||	// Symmetric
					s_fileExtension[1] == 'u' ||	// Unsymmetric
					s_fileExtension[1] == 'h' ||	// Hermitian
					s_fileExtension[1] == 'g' ||	// Skew symmetric
					s_fileExtension[1] == 'r'		// Rectangular
				) && (
					// Third Character of the Extension
					s_fileExtension[2] == 'a' ||	// Assembled
					s_fileExtension[2] == 'e'		// Elemental matrices (unassembled)
				))
			)
			return true;
		return false;
	}

	bool isMeTiSFormat(string s_fileExtension){
		if (s_fileExtension == "graph")
			return true;
		return false;
	}

}
