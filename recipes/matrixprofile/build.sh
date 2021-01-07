apt install build-essential


mkdir ~/src
cd ~/src
git clone https://github.com/matrix-profile-foundation/matrixprofile.git
cd matrixprofile

pip install -r requirements.txt


pip install -e .
