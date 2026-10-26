import yara

rules = yara.compile(source='rule t { strings: $a = "conda" condition: $a }')
matches = rules.match(data=b"hello conda")
assert [m.rule for m in matches] == ["t"], matches

# the hash module is only available when yara-python is built with OpenSSL
rules = yara.compile(source='import "hash" rule h { condition: hash.md5(0, filesize) == "5d41402abc4b2a76b9719d911017c592" }')
assert [m.rule for m in rules.match(data=b"hello")] == ["h"]
print("yara", yara.__version__, "OK")
