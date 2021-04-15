import glob
import os

from setuptools import setup, find_packages

setup(
    name='simclr',
    version='1.0',
    url='https://github.com/google-research/simclr',
    packages=['simclr'],
    license='Apache-2.0',
    license_file='LICENSE',
    description='A Simple Framework for Contrastive Learning of Visual Representations'
)