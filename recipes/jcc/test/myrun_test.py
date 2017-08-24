import sys, os

try:
    import jcc
    tmp = jcc.initVM()
    print ("JCC test OK")
    print ('java version', tmp.java_version)
    try:
    	print ('JCC_JDK = ', os.environ['JCC_JDK'])
    except:
    	pass

except:
    print ('JCC Error')
    try:
    	print ('JCC_JDK = ', os.environ['JCC_JDK'])
    	print ('PATH = ', os.environ['PATH'])
    except:
    	pass
    raise

sys.exit(False)