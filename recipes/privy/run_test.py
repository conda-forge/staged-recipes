# basic smoke test of privy
import privy
password = b'password'
data = b'secret'
encrypted = privy.hide(data, password)
assert privy.peek(encrypted, password) == data
