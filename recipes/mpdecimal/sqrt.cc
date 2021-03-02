#include <mpdecimal.h>
#include <decimal.hh>


using decimal::Decimal;
using decimal::DecInexact;
using decimal::DecRounded;
using decimal::context;


int
main(void)
{
    int ret = 0;

    context.prec(38);
    context.traps(0);

    Decimal a = Decimal("1844674407370955161500000000100000000001").sqrt();
    std::string rstring = a.to_sci();

    if (rstring != "42949672959999999998.835846782894805074" ||
        context.status() != (DecInexact|DecRounded)) {
        ret = 1;
    }

    return ret;
}
