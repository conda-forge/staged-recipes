#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cat > test.lua << EOF
local uv = require('luv')
local timer = uv.new_timer()
timer:start(1000, 0, function()
	print("Awake!")
	timer:close()
end)
print("Sleeping");
uv.run()
EOF

result="$(luajit test.lua | xargs )"
if [[ "${result}" != 'Sleeping Awake!' ]]; then
	echo 'Expected "Sleeping Awake!" but recieved"' "\"${result}\""
	exit 1
fi
