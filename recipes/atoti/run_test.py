import os

os.environ["JAVA_TOOL_OPTIONS"]="-Djna.nosys=true"

import atoti as tt
import pandas as pd

session = tt.create_session()

df = pd.DataFrame({
  "a": ["a1","a2", "a3"],
  "b": [100.0,200.0,300.0],
})
store = session.read_pandas(df, keys=["a"])
cube = session.create_cube(store)
cube.query()

