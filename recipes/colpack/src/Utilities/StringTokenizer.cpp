/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include <vector>
#include <string>

using namespace std;

#include "Definitions.h"

#include "StringTokenizer.h"

namespace ColPack
{
	//Public Constructor 4151
	StringTokenizer::StringTokenizer()
	{

	}


	//Public Constructor 4152
	StringTokenizer::StringTokenizer(char * InputChar)
	{
	  string TempInputString(InputChar);

	  InputString = TempInputString;
	  TokenString = InputString;

	}


	//Public Constructor 4153
	StringTokenizer::StringTokenizer(char * InputChar, char * DelimiterChar)
	{
	  string TempInputString(InputChar);
	  string TempDelimiterString(DelimiterChar);

	  InputString = TempInputString;
	  TokenString = InputString;

	  DelimiterString = TempDelimiterString;

	}


	//Public Constructor 4154
	StringTokenizer::StringTokenizer(string InputChar, char * DelimiterChar)
	{
	  string TempDelimiterString(DelimiterChar);

	  InputString = InputChar;
	  TokenString = InputString;

	  DelimiterString = TempDelimiterString;

	}


	//Public Constructor 4155
	StringTokenizer::StringTokenizer(string InputChar, string DelimiterChar)
	{
	  InputString = InputChar;
	  TokenString = InputString;

	  DelimiterString = DelimiterChar;

	}


	//Public Destructor 4156
	StringTokenizer::~StringTokenizer()
	{


	}


	//Public Function 4157
	int StringTokenizer::CountTokens()
	{
		int TokenCounter = 1;

		int DelimiterPosition;

		int LastPosition;

		int TokenStringLength = TokenString.size();
		int DelimiterStringLength = DelimiterString.size();

		string DelimiterSubString;

		if(TokenStringLength == 0)
		{
			return(0);
		}

		if(DelimiterStringLength == 0)
		{
			return(1);
		}

		DelimiterPosition = 0;
		LastPosition = 0;

		for ( ; ; )
		{

			DelimiterPosition = TokenString.find(DelimiterString, DelimiterPosition);

			if(DelimiterPosition == 0)
			{
				DelimiterPosition += DelimiterStringLength;

				continue;
			}

			if((DelimiterPosition < 0) || (DelimiterPosition == TokenStringLength))
			{
				return(TokenCounter);
			}

			if(DelimiterStringLength != (DelimiterPosition - LastPosition))
			{
				//      cout<<"Delimiter Position = "<<DelimiterPosition<<endl;

				TokenCounter++;
			}

			LastPosition = DelimiterPosition;

			DelimiterPosition += DelimiterStringLength;

		}
	}



	//Public Function 4158
	int StringTokenizer::CountTokens(char * DelimiterChar)
	{
	  SetDelimiterString(DelimiterChar);

	  return(CountTokens());
	}



	//Public Function 4159
	string StringTokenizer::GetDelimiterString() const
	{
	  return(DelimiterString);
	}



	//Public Function 4160
	string StringTokenizer::GetFirstToken()
	{
	  int TokenCount = 0;

	  string StringToken;

	  TokenString = InputString;

	  while(HasMoreTokens())
	  {
		if(TokenCount == 1)
		{
		  break;
		}

		StringToken = GetNextToken();

		TokenCount++;

	  }

	  return(StringToken);
	}


	//Public Function 4161
	string StringTokenizer::GetInputString() const
	{
	  return(InputString);
	}


	//Public Function 4162
	string StringTokenizer::GetLastToken()
	{
	  string StringToken;

	  TokenString = InputString;

	  while(HasMoreTokens())
	  {
		StringToken = GetNextToken();
	  }

	  return(StringToken);

	}


	//Public Function 4163
	string StringTokenizer::GetNextToken()
	{
	  string Token;

	  int DelimiterPosition;

	  int TokenStringLength = TokenString.size();
	  int DelimiterStringLength = DelimiterString.size();

	  string DelimiterSubString;

	  if (TokenStringLength == 0)
	  {
		return(NULL);
	  }

	  if (DelimiterStringLength == 0)
	  {
		return(InputString);
	  }

	  DelimiterPosition = TokenString.find(DelimiterString);

	  if(DelimiterPosition == 0)
	  {
		for ( ; ; )
		{
		  if(TokenString.substr(0, DelimiterStringLength) == DelimiterString)
		  {
			TokenString.erase(0, DelimiterStringLength);
		  }
		  else
		  {
			break;
		  }
		}

		DelimiterPosition = TokenString.find(DelimiterString);
	  }

	  if(DelimiterPosition < 0)
	  {
		Token = TokenString;

		TokenString.erase();
	  }
	  else
	  {

		Token = TokenString.substr(0, DelimiterPosition);

		TokenString.erase(0, DelimiterPosition+DelimiterStringLength);


		DelimiterPosition = 0;

		for ( ; ; )
		{
		  if(TokenString.substr(0, DelimiterStringLength) == DelimiterString)
		  {
			TokenString.erase(0, DelimiterStringLength);
		  }
		  else
		  {
			break;
		  }
		}

	  }

	  return(Token);
	}


	//Public Function 4164
	string StringTokenizer::GetNextToken(char * DelimiterChar)
	{
	  SetDelimiterString(DelimiterChar);

	  return(GetNextToken());
	}


	//Public Function 4165
	string StringTokenizer::GetToken(int TokenPosition)
	{
	  int TokenCount = 0;

	  string StringToken;

	  TokenString = InputString;

	  while(HasMoreTokens())
	  {
		if(TokenCount == TokenPosition)
		{
		  break;
		}

		StringToken = GetNextToken();

		TokenCount++;
	  }

	  return(StringToken);
	}


	//Public Function 4166
	int StringTokenizer::HasMoreTokens()
	{
	  return(CountTokens());
	}


	//Public Function 4167
	int StringTokenizer::HasMoreTokens(char * DelimiterChar)
	{
	  SetDelimiterString(DelimiterChar);

	  return(HasMoreTokens());
	}


	//Public Function 4168
	int StringTokenizer::SetInputString(char * InputChar)
	{
	  string TempInputString(InputChar);

	  InputString = TempInputString;
	  TokenString = InputString;

	  return(0);
	}


	//Public Function 4169
	int StringTokenizer::SetDelimiterString(char * DelimiterChar)
	{
	  string TempDelimiterString(DelimiterChar);

	  DelimiterString = TempDelimiterString;

	  return(0);
	}

}
