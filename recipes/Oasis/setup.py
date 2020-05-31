from setuptools import setup , find_packages

with open("README.md", "r") as fh:
    long_description = fh.read()

setup(
    name='Oasis-Optimization',
    version='0.1.1',
    description='Optimization Algorithm',
	author='Mostafa Farrag',
	author_email='moah.farag@gmail.come',
	url='https://github.com/MAfarrag/Oasis',
    keywords=['Optimization', 'Harmony Search'],
    long_description=long_description,
    long_description_content_type="text/markdown",
	License="MIT" ,
    zip_safe=False, 
    packages=find_packages(),
    classifiers=[	
    'Development Status :: 4 - Beta',
    'Environment :: Console',
    'Intended Audience :: Developers',
    'Natural Language :: English',
    'Programming Language :: Python',
    'Programming Language :: Python :: 2.7',
    'Programming Language :: Python :: 3.5',
    'Programming Language :: Python :: 3.6',
    'Programming Language :: Python :: 3.7',
    'Programming Language :: Python :: 3.8',
    'Topic :: Software Development',
    ]
	 )