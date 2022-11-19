# Remove the setup_requires section since it
# requies conan which we don't need for conda(-forge) builds
import configparser
config = configparser.ConfigParser()
with open('setup.cfg', 'r', encoding='utf-8') as f:
    config.read_file(f)

config['options'].pop('setup_requires', None)
with open('setup.cfg', 'w', encoding='utf-8') as f:
    config.write(f)
