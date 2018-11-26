from distutils.core import setup
from distutils.command.build_py import build_py

setup(
    name='paintera',
    version='0.8.2',
    author='Philipp Hanslovsky',
    author_email='hanslovskyp@janelia.hhmi.org',
    description='paintera',
    url='https://github.com/saalfeldlab/paintera',
    py_modules=['paintera'],
    entry_points={
        'console_scripts': [
            'paintera=paintera:jgo_paintera',
            'paintera-show-container=paintera:jgo_paintera_show_container',
        ]
    },
    install_requires=['jgo', 'psutil', 'paintera-conversion-helper']
)
