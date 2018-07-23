import os

PWD = os.getcwd() # current dir
SP_DIR = os.environ['SP_DIR'] # site-packages dir
PREFIX = os.environ['PREFIX'] # install prefix

EPICS_HOST_ARCH = os.environ['EPICS_HOST_ARCH']
EPICS_INSTALL_PATH = os.path.join(PREFIX, 'epics')
EPICS_BIN_PATH = os.path.join(EPICS_INSTALL_PATH, 'bin', EPICS_HOST_ARCH)

# set INSTALLATION_LOCATION in CONFIG_SITE
open('configure/CONFIG_SITE', 'ab').write(('\nINSTALL_LOCATION = $(TOP)/%s\n' % os.path.relpath(EPICS_INSTALL_PATH, os.path.curdir).replace('\\', '/')).encode('utf8'))

# create an epics-base.pth file so that epics bin dir is added to the PATH
if not os.path.exists(SP_DIR):
    os.makedirs(SP_DIR)
open(os.path.join(SP_DIR, 'epics-base.pth'), 'w').write(os.path.relpath(EPICS_BIN_PATH, SP_DIR))
