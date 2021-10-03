ls -R | awk '
/:$/&&f{s=$0;f=0}
/:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
NF&&f{ print s"/"$0 }'
python ./core/scripts/mk_make.py
cd build
make
sudo make install
