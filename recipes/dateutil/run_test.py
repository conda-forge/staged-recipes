from dateutil.relativedelta import relativedelta
from dateutil.easter import easter
from dateutil.rrule import rrule, YEARLY, FR
from dateutil.parser import parse

now = parse("Sat Oct 11 17:13:46 UTC 2003")
today = now.date()
print("Today is: %s" % today)
assert str(today) == '2003-10-11'

year = rrule(YEARLY, dtstart=now, bymonth=8,
             bymonthday=13, byweekday=FR)[0].year
rdelta = relativedelta(easter(year), today)

print("Year with next Aug 13th on a Friday is: %s" % year)
assert str(year) == '2004'
print("How far is the Easter of that year: %s" % rdelta)
assert str(rdelta) == 'relativedelta(months=+6)'
print("And the Easter of that year is: %s" % (today+rdelta))
assert str(today+rdelta) == '2004-04-11'
