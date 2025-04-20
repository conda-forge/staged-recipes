#!/usr/bin/env python
"""
Script to generate __init__.py for pgadmin4 package to avoid circular imports
"""
import os
import re
import sys
import types
from pathlib import Path

def extract_config_values(config_path):
    """Extract essential configuration values from config.py with improved parsing"""
    # Default fallback values
    config_values = {
        'APP_NAME': "'pgAdmin 4'",
        'APP_RELEASE': 9,
        'APP_REVISION': 2,
        'APP_SUFFIX': '',
        'APP_VERSION': "'%s.%s-%s' % (config.APP_RELEASE, config.APP_REVISION, config.APP_SUFFIX)",
        'AUTHENTICATION_SOURCES': "['internal']",
        'AZURE_CREDENTIAL_CACHE_DIR': "os.path.join(config.DATA_DIR, 'azurecredentialcache')",
        'CONFIG_DATABASE_CONNECTION_MAX_OVERFLOW': '100',
        'CONFIG_DATABASE_CONNECTION_POOL_SIZE': '5',
        'CONFIG_DATABASE_URI': "''",
        'CONSOLE_LOG_FORMAT': "'%(asctime)s: %(levelname)s\t%(name)s:\t%(message)s'",
        'CONSOLE_LOG_LEVEL': "logging.WARNING",
        'DATA_DIR': "os.path.join(os.path.expanduser('~'), '.pgadmin')",
        'FILE_LOG_FORMAT': "'%(asctime)s: %(levelname)s\t%(name)s:\t%(message)s'",
        'FILE_LOG_LEVEL': "logging.WARNING",
        'JSON_LOGGER': False,
        'LOG_FILE': "os.path.join(config.DATA_DIR, 'pgadmin4' + '.log')",
        'LOG_ROTATION_AGE': 1440,
        'LOG_ROTATION_MAX_LOG_FILES': 90,
        'LOG_ROTATION_SIZE': 10,
        'PASSWORD_LENGTH_MIN': 6,
        'SERVER_MODE': True,
        'SESSION_DB_PATH': "os.path.join(config.DATA_DIR, 'sessions')",
        'SQLITE_PATH': "os.path.join(config.DATA_DIR, 'pgadmin4.db')",
        'STORAGE_DIR': "os.path.join(config.DATA_DIR, 'storage')",
    }
    return config_values

    if not os.path.exists(config_path):
        print(f"Warning: config.py not found at {config_path}, using defaults")
        return config_values

    with open(config_path, 'r') as f:
        lines = f.readlines()

    # Process line by line to handle multi-line values
    current_key = None
    current_value = ""
    for line in lines:
        line = line.strip()

        # Skip comments and empty lines
        if not line or line.startswith('#'):
            continue

        # If we're collecting a multi-line value
        if current_key and (line.endswith('\\') or current_value.endswith('\\')):
            current_value += line.rstrip('\\')
            continue

        # New key definition
        if '=' in line and not current_key:
            parts = line.split('=', 1)
            key = parts[0].strip()
            value = parts[1].strip()

            if key in config_values:
                if value.endswith('\\'):
                    # Start multi-line collection
                    current_key = key
                    current_value = value.rstrip('\\')
                else:
                    # Simple single-line value
                    config_values[key] = value
        # Finish multi-line value
        elif current_key:
            current_value += line
            config_values[current_key] = current_value
            current_key = None
            current_value = ""

    # Handle any special cases
    # Ensure env function is available in generated code
    if 'SQLITE_PATH' in config_values and 'env(' in config_values['SQLITE_PATH']:
        config_values['SQLITE_PATH'] = f"os.environ.get('SQLITE_PATH') or os.path.join(DATA_DIR, 'pgadmin4.db')"

    return config_values

def generate_init_py(output_path, config_values):
    """Generate __init__.py content"""
    init_content = """# Auto-generated __init__.py for pgadmin4 package
import logging
import os
import sys
import types

# Add package directory to path
package_dir = os.path.dirname(os.path.abspath(__file__))
if package_dir not in sys.path:
    sys.path.insert(0, package_dir)

# Create minimal config module to avoid circular imports
if 'config' not in sys.modules:
    config = types.ModuleType('config')
    config.__file__ = os.path.join(package_dir, 'config.py')
    
    # Essential configuration values
    config.APP_NAME = 'pgAdmin 4'
    config.APP_RELEASE = 9
    config.APP_REVISION = 2
    config.APP_SUFFIX = ''
    config.AUTHENTICATION_SOURCES = ['internal']
    config.CONFIG_DATABASE_CONNECTION_MAX_OVERFLOW = 100
    config.CONFIG_DATABASE_CONNECTION_POOL_SIZE = 5
    config.CONFIG_DATABASE_URI = ''
    config.CONSOLE_LOG_FORMAT = '%(asctime)s: %(levelname)s\t%(name)s:\t%(message)s'
    config.CONSOLE_LOG_LEVEL = logging.WARNING
    config.DATA_DIR = os.path.join(os.path.expanduser('~'), '.pgadmin')
    config.FILE_LOG_FORMAT = '%(asctime)s: %(levelname)s\t%(name)s:\t%(message)s'
    config.FILE_LOG_LEVEL = logging.WARNING
    config.JSON_LOGGER = False
    config.LOG_ROTATION_AGE = 1440
    config.LOG_ROTATION_MAX_LOG_FILES = 90
    config.LOG_ROTATION_SIZE = 10
    config.PASSWORD_LENGTH_MIN = 6
    config.SERVER_MODE = True
    
    config.APP_VERSION = '%s.%s-%s' % (config.APP_RELEASE, config.APP_REVISION, config.APP_SUFFIX)
    config.AZURE_CREDENTIAL_CACHE_DIR = os.path.join(config.DATA_DIR, 'azurecredentialcache')
    config.LOG_FILE = os.path.join(config.DATA_DIR, 'pgadmin4' + '.log')
    config.SESSION_DB_PATH = os.path.join(config.DATA_DIR, 'sessions')
    config.SQLITE_PATH = os.environ.get('SQLITE_PATH') or os.path.join(config.DATA_DIR, 'pgadmin4.db')
    config.STORAGE_DIR = os.path.join(config.DATA_DIR, 'storage')
    
    sys.modules['config'] = config

# Create placeholder setup module with create_app
if 'setup' not in sys.modules:
    setup = types.ModuleType('setup')
    setup.__path__ = [os.path.join(package_dir, 'setup')]
    setup.__package__ = 'setup'
    
    def check_db_tables():
        from .setup import check_db_tables as real_check_db_tables
        return real_check_db_tables()
        
    setup.check_db_tables = check_db_tables
    setup.create_app_data_directory = lambda p: p
    setup.db_upgrade = lambda p: p
    setup.get_version = lambda p: p
    setup.set_version = lambda p: p
    
    sys.modules['setup'] = setup

# Create placeholder browser module with create_app
if 'browser.server_groups' not in sys.modules:
    server_groups = types.ModuleType('browser.server_groups')
    server_groups.__path__ = [os.path.join(package_dir, 'browser/server_groups')]
    server_groups.__package__ = 'browser.server_groups'
    
    sys.modules['browser.server_groups'] = server_groups

# Create placeholder browser module with create_app
if 'browser.server_groups.servers' not in sys.modules:
    servers = types.ModuleType('browser.server_groups.servers')
    servers.__path__ = [os.path.join(package_dir, 'browser/server_groups/servers')]
    servers.__package__ = 'browser.server_groups.servers'
    
    sys.modules['browser.server_groups.servers'] = servers

# Create placeholder browser module with create_app
if 'browser.server_groups.servers.utils' not in sys.modules:
    utils = types.ModuleType('browser.server_groups.servers.utils')
    utils.__path__ = [os.path.join(package_dir, 'browser/server_groups/servers/utils')]
    utils.__package__ = 'browser.server_groups.servers.utils'
    
    utils.delete_adhoc_servers = lambda p: p
    
    sys.modules['browser.server_groups.servers.utils'] = utils

# Create placeholder browser module with create_app
if 'browser' not in sys.modules:
    browser = types.ModuleType('browser')
    browser.__path__ = [os.path.join(package_dir, 'browser')]
    browser.__package__ = 'browser'
    
    sys.modules['browser'] = browser

# Create placeholder pgadmin module with create_app
if 'pgadmin' not in sys.modules:
    pgadmin = types.ModuleType('pgadmin')
    pgadmin.__path__ = [os.path.join(package_dir, 'pgadmin')]
    pgadmin.__package__ = 'pgadmin'
    
    # Add create_app function referenced in setup.py
    def create_app(app_name=None):
        # Will be properly imported when actually needed
        from .pgadmin4.pgadmin import create_app as real_create_app
        return real_create_app(app_name)
    
    pgadmin.create_app = create_app
    sys.modules['pgadmin'] = pgadmin
# Create utils module with essential attributes
if 'pgadmin.utils' not in sys.modules:
    utils = types.ModuleType('pgadmin.utils')
    utils.__path__ = [os.path.join(package_dir, 'pgadmin/utils')]
    utils.__package__ = 'pgadmin.utils'
    
    # Essential attributes needed during import
    utils.clear_database_servers = lambda p: p
    utils.driver = type('driver', (), {})
    utils.dump_database_servers = lambda p: p
    utils.env = lambda s: os.environ.get(s)
    utils.fs_short_path = lambda p: p
    utils._handle_error = lambda p: p
    utils.heartbeat = type('heartbeat', (), {})
    utils.IS_WIN = os.name == 'nt'
    utils.KeyManager = type('KeyManager', (), {})
    utils.load_database_servers = lambda p: p
    utils.PgAdminModule = type('PgAdminModule', (), {})

    sys.modules['pgadmin.utils'] = utils
    pgadmin.utils = utils

# Create evaluate_config module
if 'pgadmin.evaluate_config' not in sys.modules:
    evaluate_config = types.ModuleType('pgadmin.evaluate_config')
    evaluate_config.__package__ = 'pgadmin.evaluate_config'
    evaluate_config.evaluate_and_patch_config = lambda: None
    
    sys.modules['pgadmin.evaluate_config'] = evaluate_config
    pgadmin.evaluate_config = evaluate_config

# Create model module with db attribute
if 'pgadmin.model' not in sys.modules:
    model = types.ModuleType('pgadmin.model')
    model.__package__ = 'pgadmin.model'
    
    model.db = type('db', (), {})
    model.Keys = type('Keys', (), {})
    model.Process = type('Process', (), {})
    model.roles_users = type('roles_users', (), {})
    model.Role = type('Role', (), {})
    model.SCHEMA_VERSION = 43
    model.ServerGroup = type('ServerGroup', (), {})
    model.Server = type('Server', (), {})
    model.Setting = type('Setting', (), {})
    model.SharedServer = type('SharedServer', (), {})
    model.UserPreference = type('UserPreference', (), {})
    model.ModulePreference = type('ModulePreference', (), {})
    model.Preferences = type('Preferences', (), {})
    model.PreferenceCategory = type('PreferenceCategory', (), {})
    model.User = type('User', (), {})
    model.Version = type('Version', (), {})

    sys.modules['pgadmin.model'] = model
    pgadmin.model = model
    
# Create authenticate module with AuthenticateModule class
if 'pgadmin.authenticate' not in sys.modules:
    authenticate = types.ModuleType('pgadmin.authenticate')
    authenticate.__package__ = 'pgadmin.authenticate'
    authenticate.__path__ = [os.path.join(package_dir, 'pgadmin/authenticate')]
    
    # Define AuthenticateModule class that accepts the required arguments
    class AuthenticateModule:
        def __init__(self, name=None, import_name=None, static_url_path=None, **kwargs):
            self.name = name
            self.import_name = import_name
            self.static_url_path = static_url_path
    
    authenticate.AuthenticateModule = AuthenticateModule
    authenticate.MODULE_NAME = 'authenticate'
    
    sys.modules['pgadmin.authenticate'] = authenticate
    pgadmin.authenticate = authenticate
    
# Create tools module with toolsModule class
if 'pgadmin.tools' not in sys.modules:
    tools = types.ModuleType('pgadmin.tools')
    tools.__package__ = 'pgadmin.tools'
    tools.__path__ = [os.path.join(package_dir, 'pgadmin/tools')]
    
    # Define ToolsModule class that accepts the required arguments
    class ToolsModule:
        def __init__(self, name=None, import_name=None, static_url_path=None, **kwargs):
            self.name = name
            self.import_name = import_name
            self.static_url_path = static_url_path
    
    tools.ToolsModule = ToolsModule
    tools.MODULE_NAME = 'tools'
    
    sys.modules['pgadmin.tools'] = tools
    pgadmin.tools = tools
    
# Create user_management module with UserManagementModule class
if 'pgadmin.tools.user_management' not in sys.modules:
    user_management = types.ModuleType('pgadmin.tools.user_management')
    user_management.__package__ = 'pgadmin.tools.user_management'
    user_management.__path__ = [os.path.join(package_dir, 'pgadmin/tools/user_management')]
    
    user_management.create_user = type('create_user', (), {})
    user_management.delete_user = type('delete_user', (), {})
    user_management.update_user = type('update_user', (), {})
    
    # Define UserManagementModules class that accepts the required arguments
    class UserManagementModules:
        def __init__(self, name=None, import_name=None, static_url_path=None, **kwargs):
            self.name = name
            self.import_name = import_name
            self.static_url_path = static_url_path
    
    user_management.UserManagementModule = UserManagementModules
    user_management.MODULE_NAME = 'user_management'
    
    sys.modules['pgadmin.tools.user_management'] = user_management
    pgadmin.tools.user_management = user_management

# Create socketio module with db attribute
if 'pgadmin.socketio' not in sys.modules:
    socketio = types.ModuleType('pgadmin.socketio')
    socketio.__package__ = 'pgadmin.socketio'

    sys.modules['pgadmin.socketio'] = socketio
    pgadmin.socketio = socketio
    
"""

    # Write to file
    with open(output_path, 'w') as f:
        f.write(init_content)

    print(f"Generated {output_path}")

def main():
    """Main function"""
    if len(sys.argv) > 1:
        config_path = sys.argv[1]
        output_path = sys.argv[2] if len(sys.argv) > 2 else 'pgadmin4/__init__.py'
    else:
        # Default paths
        script_dir = Path(__file__).parent
        config_path = script_dir / 'web/config.py'
        output_path = script_dir / 'web/__init__.py'

    config_values = extract_config_values(config_path)
    generate_init_py(output_path, config_values)

if __name__ == "__main__":
    main()
