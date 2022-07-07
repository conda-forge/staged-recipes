#!/usr/bin/python

import re
import sys

# Example command line
# parse_results.py netlib_fit2d_cbc.log 'Optimal objective <number>' -68464.293294 1e-6
# parse_results.py netlib_fit2d_cbc.log 'Optimal objective <number>' -68464.293294

# comparator = 0 -> "<="
# comparator = 1 -> "<"
# comparator = 2 -> "="
# comparator = 3 -> ">"
# comparator = 4 -> ">="

rel_level  = 1e-6
epsilon    = 1e-9
comparator = 1

if (len(sys.argv) <= 4):
    filename   = sys.argv[1]
    patterns   = sys.argv[2]
    ref_value  = float(sys.argv[3])
elif (len(sys.argv) <= 5):
    filename  = sys.argv[1]
    patterns  = sys.argv[2]
    ref_value = float(sys.argv[3])
    rel_level = float(sys.argv[4])
elif (len(sys.argv) <= 6):
    filename  = sys.argv[1]
    patterns  = sys.argv[2]
    ref_value = float(sys.argv[3])
    rel_level = float(sys.argv[4])
    comparator = int(sys.argv[5])
else:
    print('usage: parse_result.py filename pattern ref_value [rel_level=1e-6] [comparator=1]')
    sys.exit(1)

if comparator > 4:
    print('wrong value for comparator (0,1,2,3,4) here: %s' % comparator)
    comparator = 1

# Internal variables
number_re = '([-+]?\d+\.*\d*)'

# Generate the regular expression
patterns = patterns.replace('<number>', number_re)
patterns = patterns.split("<|>")

# Make sure file gets closed after being iterated
with open(filename, 'r') as f:
   # Read the file contents and generate a list with each line
   lines = f.readlines()

# Iterate each line
for line in lines:
    for pattern in patterns:
        # Regex applied to each line
        match = re.findall(pattern, line)
        if match:
            if comparator == 0: # <=
                res    = abs(float(match[0]) - ref_value) / max(abs(ref_value), epsilon)
                result = res <= rel_level
                print('abs(float(%s) - %d) / max(abs(%d), 1e-9) (=%f) <= %f ==> %s' % (match[0],ref_value,ref_value,res,rel_level,result))
            elif comparator == 1: # <
                res    = abs(float(match[0]) - ref_value) / max(abs(ref_value), epsilon)
                result = res < rel_level
                print('abs(float(%s) - %d) / max(abs(%d), 1e-9) (=%f) < %f ==> %s' % (match[0],ref_value,ref_value,res,rel_level,result))
            elif comparator == 2: # =
                res    = abs(float(match[0]) - ref_value) / max(abs(ref_value), epsilon)
                result = res == rel_level
                print('abs(float(%s) - %d) / max(abs(%d), 1e-9) (=%f) == %f ==> %s' % (match[0],ref_value,ref_value,res,rel_level,result))
            elif comparator == 3: # >
                res    = abs(float(match[0]) - ref_value) / max(abs(ref_value), epsilon)
                result = res > rel_level
                print('abs(float(%s) - %d) / max(abs(%d), 1e-9) (=%f) > %f ==> %s' % (match[0],ref_value,ref_value,res,rel_level,result))
            elif comparator == 4: # >=
                res    = abs(float(match[0]) - ref_value) / max(abs(ref_value), epsilon)
                result = res >= rel_level
                print('abs(float(%s) - %d) / max(abs(%d), 1e-9) (=%f) >= %f ==> %s' % (match[0],ref_value,ref_value,res,rel_level,result))
                
            if (not result):
                print('FAILED')
                sys.exit(-1)
            else:
                print('PASSED')
                sys.exit(0)

print('NOT FOUND')
sys.exit(-1)

