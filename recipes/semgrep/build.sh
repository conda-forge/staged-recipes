curl  --output linux.whl https://files.pythonhosted.org/packages/f3/9f/a2a0f48f9d5063ca7f6419a847b2416b78ceb5e8757e7b7ce72f4e941371/semgrep-0.46.0-cp36.cp37.cp38.cp39.py36.py37.py38.py39-none-any.whl
unzip linux.whl
cp ./semgrep-0.46.0.data/purelib/semgrep/bin/semgrep-core .
cp ./semgrep-0.46.0.data/purelib/semgrep/bin/spacegrep .

export SPACEGREP_BIN="$PWD/spacegrep"
export SEMGREP_CORE_BIN="$PWD/semgrep-core"

$PYTHON -m pip install . -vv
# the above is from Grayskull's output