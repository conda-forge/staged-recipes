// Define the SIP wrapper to the word library.

%Module word

class Word {

%TypeHeaderCode
#include <word.h>
%End

public:
    Word(const char *w);

    char *reverse() const;
};