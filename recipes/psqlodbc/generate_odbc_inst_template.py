import configparser
import os

pjoin = os.path.join

PREFIX = os.environ['PREFIX']

if not os.path.exists(pjoin(PREFIX, 'etc')):
    os.mkdir(pjoin(PREFIX, 'etc'))


config = configparser.ConfigParser()
config['PostgreSQL ANSI'] = {
    'Description': 'PostgreSQL ODBC driver (ANSI version)',
    'Driver': pjoin(PREFIX, 'lib', 'psqlodbca.so'),
    'Debug': 0,
    'UsageCount': 1
}
config['PostgreSQL Unicode'] = {
    'Description': 'PostgreSQL ODBC driver (Unicode version)',
    'Driver': pjoin(PREFIX, 'lib', 'psqlodbcw.so'),
    'Debug': 0,
    'UsageCount': 1
}

with open(pjoin(PREFIX, 'etc', 'odbc_psqlodbc_template.ini'), 'w') as fo:
    config.write(fo)
