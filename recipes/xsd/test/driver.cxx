// file      : examples/cxx/tree/hello/driver.cxx
// copyright : not copyrighted - public domain

#include <memory>   // std::auto_ptr
#include <iostream>

#include "hello.hxx"

using namespace std;

int
main (int argc, char* argv[])
{
  if (argc != 2)
  {
    cerr << "usage: " << argv[0] << " hello.xml" << endl;
    return 1;
  }

  try
  {
    auto_ptr<hello_t> h (hello (argv[1]));

    for (hello_t::name_const_iterator i (h->name ().begin ());
         i != h->name ().end ();
         ++i)
    {
      cout << h->greeting () << ", " << *i << "!" << endl;
    }
  }
  catch (const xml_schema::exception& e)
  {
    cerr << e << endl;
    return 1;
  }
}
