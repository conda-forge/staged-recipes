import pysqlite3.dbapi2 as sqlite3

conn = sqlite3.connect(':memory:')
cursor = conn.cursor()

# Check if extension are installed.
cursor.execute('CREATE VIRTUAL TABLE testing USING fts5(data);')
