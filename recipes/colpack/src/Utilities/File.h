/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#ifndef FILE_H
#define FILE_H

#include<string>

using namespace std;

//#undef _WIN32

//define system-dependent directory separator
#ifdef _WIN32	//Windows
#define DIR_SEPARATOR "\\"
#else			//*nix
#define DIR_SEPARATOR "/"
#endif


namespace ColPack
{
	/** @ingroup group4
	 *  @brief class File in @link group4@endlink.

	 The File class is used to process file name. It should work on both Windows and *nix. A File object will
	 take a file name, parse and separate it into 3 parts: path (name prefix), name, and file extension.
	 */
	class File
	{
	  private:

		string path; //including the last DIR_SEPARATOR
		string name;
		string fileExtension; //excluding the '.'

	  public:

		File();

		File(string fileName);

		void Parse(string newFileName);

		string GetPath() const;

		string GetName() const;

		///GetFileExtension excluding the '.'
		string GetFileExtension() const;

		string GetFullName() const;

		void SetPath(string newPath);

		void SetName(string newName);

		void SetFileExtension(string newFileExtension);

	};

	///Tell whether or not the file format is MatrixMarket from its extension
	bool isMatrixMarketFormat(string s_fileExtension);

	///Tell whether or not the file format is HarwellBoeing from its extension
	bool isHarwellBoeingFormat(string s_fileExtension);

	///Tell whether or not the file format is MeTiS from its extension
	bool isMeTiSFormat(string s_fileExtension);
}
#endif
