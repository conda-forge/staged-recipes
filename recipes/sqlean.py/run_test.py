import sqlean

sqlean.extensions.enable_all()

if __name__ == "__main__":
    conn = sqlean.connect(":memory:")
    cur = conn.execute("select median(value) from generate_series(1, 99)")
    assert cur.fetchone() == (50.0,)
    conn.close()
