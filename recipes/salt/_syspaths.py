import os
import sys

ROOT_DIR = sys.exec_prefix

# Copied from salt source: salt/syspaths.py
CONFIG_DIR = os.path.join(ROOT_DIR, 'etc', 'salt')
CACHE_DIR = os.path.join(ROOT_DIR, 'var', 'cache', 'salt')
SOCK_DIR = os.path.join(ROOT_DIR, 'var', 'run', 'salt')
SRV_ROOT_DIR = os.path.join(ROOT_DIR, 'srv')
BASE_FILE_ROOTS_DIR = os.path.join(SRV_ROOT_DIR, 'salt')
BASE_PILLAR_ROOTS_DIR = os.path.join(SRV_ROOT_DIR, 'pillar')
BASE_MASTER_ROOTS_DIR = os.path.join(SRV_ROOT_DIR, 'salt-master')
LOGS_DIR = os.path.join(ROOT_DIR, 'var', 'log', 'salt')
PIDFILE_DIR = os.path.join(ROOT_DIR, 'var', 'run')
SPM_FORMULA_PATH = os.path.join(SRV_ROOT_DIR, 'spm', 'salt')
SPM_PILLAR_PATH = os.path.join(SRV_ROOT_DIR, 'spm', 'pillar')
SPM_REACTOR_PATH = os.path.join(SRV_ROOT_DIR, 'spm', 'reactor')
