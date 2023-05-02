#include <gsl/gsl>

int foo(gsl::not_null<int *> p)
{
    return *p;
}

int main()
{
    int ret = 0;
    return foo(&ret);
}
