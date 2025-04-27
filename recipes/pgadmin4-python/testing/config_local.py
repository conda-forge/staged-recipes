import os
from config import *

# Debug mode
DEBUG = True

# App mode
SERVER_MODE = False

# Log
CONSOLE_LOG_LEVEL = DEBUG
FILE_LOG_LEVEL = DEBUG

DEFAULT_SERVER = '127.0.0.1'

UPGRADE_CHECK_ENABLED = False

BASE_DIR = os.getcwd()

LOG_FILE = os.path.join(BASE_DIR, "var", "pgadmin4.log")
SESSION_DB_PATH = os.path.join(BASE_DIR, "var", "sessions")
STORAGE_DIR = os.path.join(BASE_DIR, "var", "storage")
SQLITE_PATH = os.path.join(BASE_DIR, "var", "pgadmin4.db")
TEST_SQLITE_PATH = os.path.join(BASE_DIR, "var", "pgadmin4.db")
AZURE_CREDENTIAL_CACHE_DIR = os.path.join(BASE_DIR, "var", "azurecredentialcache")

