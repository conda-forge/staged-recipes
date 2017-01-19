export CFLAGS="-Wall -g -m64 -pipe -O2  -fPIC ${CFLAGS}"
export CXXLAGS="${CFLAGS}"
export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

export GIT_DESCRIBE=`git describe --tags`

cat > cdat_info.py.in << EOF

Version = 'GIT_DESCRIBE'
ping_checked = False 
check_in_progress = False
def version():
    sp = Version.split("-")
    vnm = "-".join(sp[:-2])
    vlist = vnm.split(".") + sp[-2:]
    return vlist


def get_drs_dirs ():
    return ['${PREFIX}/lib']
def get_drs_libs():
    return ['drsfortran','gfortran']


sleep=60 #minutes  (int required)

actions_sent = {}

SOURCE = 'CDAT'

def get_version():
  return Version

def get_prefix():
  import sys
  return sys.prefix

def get_sampledata_path():
  import os
  try:
    return os.path.join(os.environ["UVCDAT_SETUP_PATH"],
                        "share", "uvcdat", "sample_data")
  except KeyError:
    raise RuntimeError("UVCDAT environment not configured. Please source the setup_runtime script.")

def runCheck():
    import cdat_info,os
    if cdat_info.ping_checked is False:
        check_in_progress = True
        val = None
        envanom = os.environ.get("UVCDAT_ANONYMOUS_LOG",None)
        if envanom is not None:
            if envanom.lower() in ['true','yes','y','ok']:
                val = True
            elif envanom.lower() in ['false','no','n','not']:
                val = False
            else:
                import warnings
                warnings.warn("UVCDAT logging environment variable UVCDAT_ANONYMOUS_LOG should be set to 'True' or 'False', you have it set to '%s', will be ignored" % envanom)
        if val is None: # No env variable looking in .uvcdat
            fanom = os.path.join(os.path.expanduser("~"),".uvcdat",".anonymouslog")
            if os.path.exists(fanom):
                f=open(fanom)
                for l in f.readlines():
                    sp = l.strip().split("UVCDAT_ANONYMOUS_LOG:")
                    if len(sp)>1:
                        try:
                            val = eval(sp[1])
                        except:
                            pass
                f.close()

        reload(cdat_info)
        return val

def askAnonymous(val):
        import cdat_info,os
        while cdat_info.ping_checked is False and not val in [True, False]: # couldn't get a valid value from env or file
            val2 = raw_input("Allow anonymous logging usage to help improve UV-CDAT? (you can also set the environment variable UVCDAT_ANONYMOUS_LOG to yes or     no) [yes/no]")
            if val2.lower() in ['y','yes','ok']:
                val = True
            elif val2.lower() in ['n','no','not']:
                val = False
            if val in [True,False]: # store result for next time
                try:
                    fanom = os.path.join(os.path.expanduser("~"),".uvcdat",".anonymouslog")
                    if not os.path.exists(os.path.join(os.path.expanduser("~"),".uvcdat")):
                        os.makedirs(os.path.join(os.path.expanduser("~"),".uvcdat"))
                    f=open(fanom,"w")
                    print >>f, "#Store information about allowing UVCDAT anonymous logging"
                    print >>f, "# Need sto be True or False"
                    print >>f, "UVCDAT_ANONYMOUS_LOG: %s" % val
                    f.close()
                except Exception,err:
                    pass
        else:
            if cdat_info.ping_checked:
                val = cdat_info.ping
        cdat_info.ping = val
        cdat_info.ping_checked = True
        check_in_progress = False

def pingPCMDIdb(*args,**kargs):
    import cdat_info,os
    while cdat_info.check_in_progress:
       reload(cdat_info)
    val = cdat_info.runCheck()
    if val is False:
      cdat_info.ping_checked = True
      cdat_info.ping = False
      return
    try:
      if not cdat_info.ping:
        return
    except:
      pass
    cdat_info.askAnonymous(val)
    import threading
    kargs['target']=pingPCMDIdbThread
    kargs['args']=args
    t = threading.Thread(**kargs)
    try:
        t.start()
    except:
        pass

def pingPCMDIdbThread(*args,**kargs):
    import threading
    kargs['target']=submitPing
    kargs['args']=args
    t = threading.Thread(**kargs)
    try:
        t.start()
    except:
        pass
    import time
    time.sleep(5) # Lets wait 5 seconds top for this ping to work
    if t.isAlive():
        try:
            t._Thread__stop()
        except:
            pass
def submitPing(source,action,source_version=None):
  try:
    import urllib2,sys,os,cdat_info,hashlib,urllib
    if source in ['cdat','auto',None]:
      source = cdat_info.SOURCE
    if cdat_info.ping:
      if not source in actions_sent.keys():
        actions_sent[source]=[]
      elif action in actions_sent[source]:
        return
      else:
        actions_sent[source].append(action)
      data={}
      uname = os.uname()
      data['platform']=uname[0]
      data['platform_version']=uname[2]
      data['hashed_hostname']=hashlib.sha1(uname[1]).hexdigest()
      data['source']=source
      if source_version is None:
        data['source_version']=cdat_info.get_version()
      else:
        data['source_version']=source_version
      data['action']=action
      data['sleep']=cdat_info.sleep
      data['hashed_username']=hashlib.sha1(os.getlogin()).hexdigest()
      urllib2.urlopen('http://uv-cdat.llnl.gov/UVCDATUsage/log/add/',urllib.urlencode(data))
  except Exception,err:
    pass

import os,sys
os.environ["UVCDAT_SETUP_PATH"] = sys.prefix
CDMS_INCLUDE_DAP = 'yes'
CDMS_DAP_DIR = '.'
CDMS_HDF_DIR = '.'
CDMS_GRIB2LIB_DIR = sys.prefix
CDMS_INCLUDE_GRIB2LIB = 'yes'
CDMS_INCLUDE_DRS = 'no'
CDMS_INCLUDE_HDF = 'no'
CDMS_INCLUDE_PP = 'yes'
CDMS_INCLUDE_QL = 'no'
drs_file = '${PREFIX}/lib/libdrs.a'
netcdf_directory = sys.prefix
netcdf_include_directory = sys.prefix+'/include'
cdunif_include_directories = [sys.prefix+'/include/cdms'] + [sys.prefix+'/include', sys.prefix+'/lib/libffi-3.1/include', '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk/usr/include', '/usr/X11R6/include'] + []
cdunif_library_directories = [sys.prefix+'/lib'] + get_drs_dirs() + [sys.prefix+'/lib'] +["/usr/X11/lib","/usr/X11R6/lib"]
cdunif_libraries = ['cdms', 'netcdf'] + ['netcdf'] + get_drs_libs() + [] + ['grib2c', 'png', 'jasper']
x11include = ['/usr/X11R6/include', '/usr/include', '/opt/include']
x11libdir = ['/usr/X11R6/lib', '/usr/lib', '/opt/lib']
mathlibs = ['m']
externals = sys.prefix

EOF


mkdir cdat_info_dir
sed "s/GIT_DESCRIBE/${GIT_DESCRIBE}/g;" cdat_info.py.in > cdat_info_dir/cdat_info.py
cat > cdat_info_dir/__init__.py << EOF
from cdat_info import *
EOF

cat > setup.py << EOF
from distutils.core import setup

setup (name = "cdat_info",
       packages = ['cdat_info'],
       package_dir = {'cdat_info': 'cdat_info_dir'},
      )
EOF

$PYTHON setup.py install
env
