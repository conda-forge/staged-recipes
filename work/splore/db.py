import functools
import os
import sqlite3
from typing import Any, Iterable, List, Optional, Tuple, Union

from rdkit import Chem
from rdkit.Chem import Descriptors

from splore.models import Cursor, Page, RangeFilter, SMARTSFilter, SortBy

_REVERSE_SORT_BY = {None: None, "asc": "desc", "desc": "asc"}

PER_PAGE_DEFAULT = 200


def _sort_by_to_sql(sort_by: List[SortBy], reverse: bool) -> str:

    statements = [
        " ".join((column, direction if not reverse else _REVERSE_SORT_BY[direction]))
        for column, direction in sort_by
    ]

    return f"order by {','.join(statements)}" if len(statements) > 0 else ""


def _filters_to_sql(filters: List[Union[RangeFilter, SMARTSFilter]]) -> str:

    statements = []

    for column_filter in filters:

        if isinstance(column_filter, RangeFilter):

            if column_filter.lt is not None:
                statements.append(f"{column_filter.column} < {column_filter.lt}")
            if column_filter.le is not None:
                statements.append(f"{column_filter.column} <= {column_filter.le}")
            if column_filter.gt is not None:
                statements.append(f"{column_filter.column} > {column_filter.gt}")
            if column_filter.ge is not None:
                statements.append(f"{column_filter.column} >= {column_filter.ge}")

        if isinstance(column_filter, SMARTSFilter):
            statements.append(f"smarts_match(smiles,'{column_filter.smarts}')")

    return f"where {' and '.join(statements)}" if len(statements) > 0 else ""


@functools.lru_cache(16384)
def _filter_by_pattern(smiles: str, pattern: str) -> bool:

    molecule: Chem.Mol = Chem.MolFromSmiles(smiles)
    q_mol: Chem.Mol = Chem.MolFromSmarts(pattern)

    return molecule.HasSubstructMatch(q_mol)


class SploreDBPage:
    @property
    def has_next(self) -> bool:
        return len(self.rows) > 0 and self._cursor_next is not None

    @property
    def has_prev(self) -> bool:
        return len(self.rows) > 0 and self._cursor_prev is not None

    @property
    def next(self) -> Page:
        return (self._cursor_end or self._cursor_prev), "next"

    @property
    def prev(self) -> Page:
        return (self._cursor_start or self._cursor_next), "prev"

    @property
    def current(self) -> Page:
        if self.backwards:
            return self._cursor_next, "prev"
        else:
            return self._cursor_prev, "next"

    def __init__(
        self,
        cursor: Cursor,
        backwards: bool,
        per_page: int,
        keys: List[Cursor],
        rows: List[Tuple[Any]],
    ):

        self.per_page = per_page
        self.backwards = backwards

        # try and retrieve an extra row to see if we can go further forward / back
        self.rows = rows[:per_page]

        extra_keys = keys[per_page:]
        keys = keys[:per_page]

        cursors = (
            # current =
            cursor,
            # start and end
            None if len(keys) == 0 else keys[0],
            None if len(keys) == 0 else keys[-1],
            # next
            None if len(extra_keys) == 0 else extra_keys[0],
        )

        if backwards:  # make sure to flip the results if getting previous
            self.rows = self.rows[::-1]
            cursors = cursors[::-1]

        (
            self._cursor_prev,
            self._cursor_start,
            self._cursor_end,
            self._cursor_next,
        ) = cursors

    def __len__(self):
        return len(self.rows)


class SploreDB:
    """A wrapper around a SQLite database that can store and be queried for RDKit
    molecules
    """

    @property
    def n_molecules(self) -> int:
        return self._connection.execute("select count(*) from molecules").fetchone()[0]

    def __init__(self, file_path: Union[os.PathLike, str], clear_existing: bool = True):

        self._file_path = file_path

        self._connection = sqlite3.connect(file_path)
        self._connection.create_function(
            "smarts_match", 2, _filter_by_pattern, deterministic=True
        )

        self._create_schema()

        if clear_existing:
            self.clear()

    def __del__(self):

        if self._connection is not None:
            self._connection.close()

    def _create_schema(self):

        with self._connection:

            self._connection.execute(
                "create table if not exists info (version integer)"
            )
            db_info = self._connection.execute("select * from info").fetchall()

            if len(db_info) == 0:
                self._connection.execute("insert into info values(1)")
            else:
                assert len(db_info) == 1 and db_info[0] == (1,)

            self._connection.execute(
                "create table if not exists molecules "
                "(smiles text, n_heavy integer, weight real)"
            )
            self._connection.execute(
                "create index if not exists n_heavy_idx on molecules(n_heavy)"
            )
            self._connection.execute(
                "create index if not exists weight_idx on molecules(weight)"
            )

    def create(self, molecules: Iterable[Chem.Mol]):

        with self._connection:

            self._connection.executemany(
                "insert into molecules (smiles, n_heavy, weight) values (?, ?, ?)",
                (
                    (
                        Chem.MolToSmiles(molecule),
                        molecule.GetNumHeavyAtoms(),
                        Descriptors.ExactMolWt(molecule),
                    )
                    for molecule in molecules
                ),
            )

    def read_all(
        self,
        page: Page = (None, "next"),
        per_page: int = PER_PAGE_DEFAULT,
        sort_by: Optional[SortBy] = None,
        filters: Optional[List[Union[RangeFilter, SMARTSFilter]]] = None,
    ) -> SploreDBPage:

        cursor, move_to = page
        backwards = {"prev": True, "next": False}[move_to]

        order_by_terms = ([] if not sort_by else [sort_by]) + [("ROWID", "asc")]
        order_by_sql = _sort_by_to_sql(order_by_terms, reverse=backwards)

        filters = filters if filters else []
        where_sql = _filters_to_sql(filters)

        if cursor is not None:

            iterable_cursor = (cursor,) if not isinstance(cursor, tuple) else cursor

            lhs = tuple(
                column
                if (
                    (not backwards and order_by == "asc")
                    or (backwards and order_by == "desc")
                )
                else value
                for value, (column, order_by) in zip(iterable_cursor, order_by_terms)
            )
            rhs = tuple(
                column
                if not (
                    (not backwards and order_by == "asc")
                    or (backwards and order_by == "desc")
                )
                else value
                for value, (column, order_by) in zip(iterable_cursor, order_by_terms)
            )
            assert len(lhs) == len(rhs) and len(lhs) == len(iterable_cursor)

            if len(lhs) == 1:
                page_sql = f"{lhs[0]} > {rhs[0]}"
            else:
                page_sql = f"({','.join(map(str, lhs))}) > ({','.join(map(str, rhs))})"

            where_sql = (
                f"{where_sql} and {page_sql}"
                if where_sql != ""
                else f"where {page_sql}"
            )

        required_fields = [column for column, _ in order_by_terms] + ["smiles"]

        for range_filter in filters:
            if (
                not isinstance(filter, RangeFilter)
                or range_filter.column in required_fields
            ):
                continue
            required_fields.append(range_filter.column)

        select_sql = ",".join(required_fields)

        limit = per_page + 1

        statement = (
            f"select {select_sql} from molecules "
            f"{where_sql} "
            f"{order_by_sql} "
            f"limit {limit} "
        )

        rows = self._connection.execute(statement).fetchall()
        keys = [row[: len(order_by_terms)] for row in rows]

        return SploreDBPage(cursor, backwards, per_page, keys, rows)

    def read(self, molecule_id: int) -> Tuple[str]:

        return self._connection.execute(
            f"select smiles " f"from molecules " f"where ROWID = {molecule_id}"
        ).fetchone()

    def clear(self):

        with self._connection:
            self._connection.execute("delete from molecules")
