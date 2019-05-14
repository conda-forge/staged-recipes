@echo on
cd dist
copy scripts\owlrl.py owlrl\_cli.py
python -m pip install . --no-deps -vv
