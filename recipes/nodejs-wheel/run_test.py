from nodejs_wheel import (
    node,
    npm,
    npx,
)


return_code0 = node(["--version"])
assert return_code0 == 0

return_code1 = npm(["--version"])
assert return_code1 == 0

return_code2 = npx(["--version"])
assert return_code2 == 0
