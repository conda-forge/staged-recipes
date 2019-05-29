"""
AnteChamber PYthon Parser interfacE

A tool based in Python to use Antechamber to generate topologies for chemical compounds and to interface with others python applications like CCPN or ARIA.
"""

from setuptools import setup

setup(name='acpype',
      version='2019.03.22.14.36',
      description='ACPYPE - AnteChamber PYthon Parser interfacE',
      classifiers=[
          'Intended Audience :: Science/Research',
          'Natural Language :: English',
          'Programming Language :: Python :: 3.7',
          'Topic :: Scientific/Engineering :: Bio-Informatics'
      ],
      url='https://github.com/alanwilter/acpype',
      author='Alan Wilter Sousa da Silva',
      author_email='alanwilter@gmail.com',
      license='GPL3',
      packages=['anaconda','ffamber_additions', 'test'],
      keywords=['acpype'],
      include_package_data=True,
      entry_points={'console_scripts': ['acpype = anaconda.acpype:init_main']},
      zip_safe=False)
