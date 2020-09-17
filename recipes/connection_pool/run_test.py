from connection_pool import ConnectionPool

class Connection(object):
    def __init__(self, **kwargs):
        self.args = kwargs
        self.state = 'Connected'

    def close(self):
        self.state = 'Closed'
    
def connect():
    return Connection()

def close(connection):
    connection.close()

pool = ConnectionPool(create=connect, close=close,
                      max_size=10, max_usage=10000, idle=60, ttl=120)

with pool.item() as connection:
    assert connection.state == 'Connected'
