/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#ifndef STRINGTOKENIZER_H
#define STRINGTOKENIZER_H

using namespace std;

namespace ColPack
{
	/** @ingroup group4
	 *  @brief class StringTokenizer in @link group4@endlink.

	 The string tokenizer class is provided as an utility class to assist in reading various matrix and graph
	 format files. As an input file is read line by line as strings, this class is used to tokenize the lines with one
	 or more tokenizing strings which are generally the separators used in the input file. The string tokens are
	 then restored to the intended data format without losing the actual precision of the original data. A string
	 tokenizer class can be instantiated with an input string and an input tokenizer string or character array.
	 */
	class StringTokenizer
	{
	 private:

		string DelimiterString;
		string InputString;
		string TokenString;

	 public:

		//Public Constructor 4151
		StringTokenizer();

		//Public Constructor 4152
		StringTokenizer(char *);

		//Public Constructor 4153
		StringTokenizer(char *, char *);

		//Public Constructor 4154
		StringTokenizer(string, char *);

		//Public Constructor 4155
		StringTokenizer(string, string);

		//Public Destructor 4156
		~StringTokenizer();

		//Public Function 4157
		int CountTokens();

		//Public Function 4158
		int CountTokens(char *);

		//Public Function 4159
		string GetDelimiterString() const;

		//Public Function 4160
		string GetFirstToken();

		//Public Function 4161
		string GetInputString() const;

		//Public Function 4162
		string GetLastToken();

		//Public Function 4163
		string GetNextToken();

		//Public Function 4164
		string GetNextToken(char *);

		//Public Function 4165
		string GetToken(int);

		//Public Function 4166
		int HasMoreTokens();

		//Public Function 4167
		int HasMoreTokens(char *);

		//Public Function 4168
		int SetInputString(char *);

		//Public Function 4169
		int SetDelimiterString(char *);

	};
}
#endif
