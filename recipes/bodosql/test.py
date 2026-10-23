import os
import pandas as pd

import bodosql

os.environ["BODO_NUM_WORKERS"] = "3"

df = pd.DataFrame({"A": [1, 2, 3]})
bc = bodosql.BodoSQLContext({"TABLE1": df})
res = bc.sql("SELECT SUM(A) as OUTPUT FROM TABLE1")
assert res["OUTPUT"].iloc[0] == 6
