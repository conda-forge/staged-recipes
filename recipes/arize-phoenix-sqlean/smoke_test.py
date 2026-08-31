import sqlean

sqlean.extensions.enable_all()

conn = sqlean.connect(":memory:")

# uuid extension
(uuid,) = conn.execute("select uuid4()").fetchone()
assert uuid

# stats extension
(median,) = conn.execute(
    "select median(value) from (select 1 as value union select 2 union select 3)"
).fetchone()
assert median == 2

# regexp extension
(match,) = conn.execute("select regexp_like('phoenix', 'ph?')").fetchone()
assert match == 1

print("sqlite version:", sqlean.sqlite_version)
print("sqlean smoke test OK")
