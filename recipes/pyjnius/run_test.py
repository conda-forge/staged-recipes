import jnius
from jnius import autoclass

AL = autoclass( 'java.util.ArrayList' )
al = AL()
hw = 'Hello World!'
for c in hw:
	al.add( c )
print( al.toString() )

if al.size() != len( hw ):
	raise RuntimeError('Length of ArrayList and python string are not the same!')

for idx, c in enumerate( hw ):
	if c != al.get( idx ):
		raise RuntimeError('Character mismatch!')

