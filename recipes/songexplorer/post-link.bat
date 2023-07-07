echo ********** IMPORTANT !!! ********** >> %PREFIX%\.messages.txt
echo cut and paste the following into the command line to finish the installation: >> %PREFIX%\.messages.txt
echo conda activate songexplorer >> %PREFIX%\.messages.txt
echo pip3 install "tensorflow<2.11" >> %PREFIX%\.messages.txt
echo optionally, to use video in songexplorer, cut and paste the following too: >> %PREFIX%\.messages.txt
echo mamba install python==3.10 av=8.1 git >> %PREFIX%\.messages.txt
echo pip3 install -e git+https://github.com/soft-matter/pims.git@7bd634015ecbfeb7d92f9f9d69f8b5bb4686a6b4#egg=pims >> %PREFIX%\.messages.txt
echo ********** IMPORTANT !!! ********** >> %PREFIX%\.messages.txt
