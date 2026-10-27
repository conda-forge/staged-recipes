import os
import pandas as pd

import bodosql

os.environ["BODOSQL_CPP_BACKEND"] = "1"
os.environ["BODOSQL_CPP_BACKEND_FALLBACK"] = "0"
os.environ["BODO_DATAFRAME_LIBRARY_RUN_PARALLEL"] = "0"

df = pd.DataFrame({"A": [1, 2, 3]})
bc = bodosql.BodoSQLContext({"TABLE1": df})
res = bc.sql("SELECT SUM(A) as OUTPUT FROM TABLE1")
assert res["OUTPUT"].iloc[0] == 6
