import functools
import os
from typing import List, Optional, Union

from fastapi import FastAPI, Path, Query
from fastapi.responses import Response
from pkg_resources import resource_filename
from pydantic import BaseSettings, ValidationError
from starlette.middleware.cors import CORSMiddleware
from starlette.responses import HTMLResponse, RedirectResponse
from starlette.staticfiles import StaticFiles

import splore
from splore.db import SploreDB
from splore.io import molecule_to_svg
from splore.models import (
    GETMoleculeResponse,
    GETMoleculesResponse,
    Page,
    PaginationLinks,
    PaginationMetadata,
    RangeFilter,
    SMARTSFilter,
    SortBy,
)
from splore.parsing import (
    FILTER_REGEX,
    PAGE_REGEX,
    SORT_REGEX,
    encode_base64,
    encode_cursor,
    encode_page,
    encode_range_filter,
    encode_sort_by,
    parse_base64,
    parse_page,
    parse_range_filter,
    parse_sort_by,
)


class Settings(BaseSettings):

    SPLORE_API_PORT: int = 8000
    SPLORE_API_DEFAULT_PER_PAGE = 200

    SPLORE_DB_PATH: str = "splore-db.sqlite"


settings = Settings()

db = SploreDB(settings.SPLORE_DB_PATH, False)

static_directory = resource_filename("splore", "_static")

if not os.path.isdir(static_directory) or not os.path.isfile(
    os.path.join(static_directory, "index.html")
):
    raise RuntimeError("`index.html` is missing - make sure `frontend` was built.")

app = FastAPI(title="splore", openapi_url="/api/openapi.json", docs_url="/api/docs")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.mount("/static", StaticFiles(directory=static_directory), name="static")


@app.get("/")
def get_app_angular():

    with open(os.path.join(static_directory, "index.html")) as file_index:
        html_content = file_index.read().replace(
            "PLACEHOLDER_BASE_URL", f"http://localhost:{settings.SPLORE_API_PORT}/api"
        )

    return HTMLResponse(html_content, status_code=200)


@app.get("/api")
async def get_root():
    return {
        "version": splore.__version__,
        "settings": {
            "api_port": settings.SPLORE_API_PORT,
            "api_default_per_page": settings.SPLORE_API_DEFAULT_PER_PAGE,
            "db_path": settings.SPLORE_DB_PATH,
        },
    }


def _build_molecules_url(
    page: Optional[Page],
    per_page: int,
    sort_by: Optional[SortBy],
    filters=Optional[List[Union[RangeFilter, SMARTSFilter]]],
) -> Optional[str]:

    if page is None:
        return None

    base_url = "/api/molecules"
    query_paths = [f"page={encode_page(page)}", f"per_page={per_page}"]

    if sort_by is not None:
        query_paths.append(f"sort_by={encode_sort_by(sort_by)}")

    for column_filter in filters if filters else []:

        if isinstance(column_filter, SMARTSFilter):
            query_paths.append(f"substr={encode_base64(column_filter.smarts)}")
        elif isinstance(column_filter, RangeFilter):
            query_paths.extend(
                f"{column_filter.column}={filter_str}"
                for filter_str in encode_range_filter(column_filter)
            )
        else:
            raise NotImplementedError

    return "?".join(
        [base_url] + ([] if len(query_paths) == 0 else ["&".join(query_paths)])
    )


@app.get("/api/molecules")
async def get_molecules(
    page_param: Optional[str] = Query(None, alias="page", regex=PAGE_REGEX),
    per_page: int = Query(settings.SPLORE_API_DEFAULT_PER_PAGE, ge=1),
    sort_by_param: Optional[str] = Query(None, alias="sort_by", regex=SORT_REGEX),
    smarts_param: Optional[str] = Query(None, alias="substr"),
    n_heavy: Optional[List[str]] = Query(None, alias="n_heavy", regex=FILTER_REGEX),
):

    page = parse_page(page_param)
    sort_by = parse_sort_by(sort_by_param)

    smarts = None if not smarts_param else parse_base64(smarts_param)

    filters = []

    if smarts:
        filters.append(SMARTSFilter(smarts=smarts))
    if n_heavy:
        le, lt, gt, ge = parse_range_filter(n_heavy, int)
        filters.append(RangeFilter(column="n_heavy", le=le, lt=lt, gt=gt, ge=ge))

    # define a partial so that the self, first, and last calls to `read_all` are same
    get_page = functools.partial(
        db.read_all, per_page=per_page, sort_by=sort_by, filters=filters
    )
    get_url = functools.partial(
        _build_molecules_url, per_page=per_page, sort_by=sort_by, filters=filters
    )

    page = get_page(page)

    self_cursor = None if len(page) == 0 else page.current

    prev_cursor = None if not page.has_prev else page.prev
    next_cursor = None if not page.has_next else page.next

    first_cursor, last_cursor = None, None

    if len(page) > 0:

        first_cursor = (None, "next")
        last_cursor = (None, "prev")

        # Handle partial first and last pages.
        if not page.has_prev and page.has_next and len(page) != page.per_page:
            return RedirectResponse(url=get_url(first_cursor))
        if not page.has_next and page.has_prev and len(page) != page.per_page:
            return RedirectResponse(url=get_url(last_cursor))

    return GETMoleculesResponse(
        _metadata=PaginationMetadata(
            cursor=None if not self_cursor else encode_cursor(self_cursor[0]),
            move_to="next" if not self_cursor else self_cursor[1],
            per_page=per_page,
            sort_by=sort_by,
            filters=filters,
        ),
        _links=PaginationLinks(
            self=get_url(self_cursor if self_cursor else page.current),
            first=get_url(first_cursor) if page.has_prev else None,
            prev=get_url(prev_cursor),
            next=get_url(next_cursor),
            last=get_url(last_cursor) if page.has_next else None,
        ),
        contents=[
            GETMoleculeResponse(
                self=f"/molecules/{molecule_id}",
                id=molecule_id,
                smiles=smiles,
                _links={"img": f"/molecules/{molecule_id}/img"},
            )
            for *_, molecule_id, smiles in page.rows
        ],
    )


@app.get("/api/molecules/{molecule_id}")
async def get_molecule(
    molecule_id: int = Path(0, ge=0),
):

    smiles, *_ = db.read(molecule_id)

    return GETMoleculeResponse(
        self=f"/molecules/{molecule_id}",
        id=molecule_id,
        smiles=smiles,
        _links={"img": f"/molecules/{molecule_id}/img"},
    )


@app.get("/api/molecules/{molecule_id}/img")
async def get_molecule_image(
    molecule_id: int = Path(0, ge=0),
):

    smiles, *_ = db.read(molecule_id)
    return Response(molecule_to_svg(smiles), media_type="image/svg+xml")


@app.get("/api/validation/substr/{value}")
async def is_substr_valid(value: str) -> bool:

    try:
        SMARTSFilter(smarts=parse_base64(value))
    except ValidationError:
        return False

    return True
