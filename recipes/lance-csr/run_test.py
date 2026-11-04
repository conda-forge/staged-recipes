import tempfile
from pathlib import Path

import lance
import pyarrow as pa
from lance_csr import CypherEngine, CypherQuery, GraphConfig, SqlQuery

people = pa.table(
    {
        "id": [1, 2, 3, 4],
        "name": ["Alice", "Bob", "Carol", "David"],
        "age": [28, 34, 29, 42],
    }
)
knows = pa.table({"src": [1, 1, 2, 3], "dst": [2, 3, 4, 4]})

config = (
    GraphConfig.builder()
    .node_table("Person", "id")
    .rel_table("KNOWS", "Person", "Person", "src", "dst")
    .build()
)

result = (
    CypherQuery("MATCH (p:Person) WHERE p.age > 30 RETURN p.name AS name ORDER BY name")
    .with_config(config)
    .execute({"Person": people})
)
assert result.to_pydict() == {"name": ["Bob", "David"]}, result

two_hops = (
    "MATCH (a:Person)-[:KNOWS]->(:Person)-[:KNOWS]->(c:Person) "
    "WHERE a.id = 1 RETURN DISTINCT c.name AS name"
)

# Lance can keep dataset files open on Windows until the process exits.
with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmp:
    datasets = {
        "Person": lance.write_dataset(people, Path(tmp) / "person.lance"),
        "KNOWS": lance.write_dataset(knows, Path(tmp) / "knows.lance"),
    }
    for use_csr in (False, True):
        engine = CypherEngine(config, datasets, use_csr=use_csr)
        out = engine.execute(two_hops)
        assert out.to_pydict() == {"name": ["David"]}, (use_csr, out)

sql = SqlQuery("SELECT count(*) AS n FROM person WHERE age >= 29").execute(
    {"person": people}
)
assert sql.to_pydict() == {"n": [3]}, sql

print("lance-csr smoke test passed")
