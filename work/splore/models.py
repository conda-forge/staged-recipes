from typing import Dict, Generic, List, Literal, Optional, Tuple, TypeVar, Union

from pydantic import BaseModel, Field, StrictInt, validator
from pydantic.generics import GenericModel
from rdkit import Chem

_T = TypeVar("_T")

OrderBy = Literal["desc", "asc"]
SortBy = Tuple[str, OrderBy]
MoveTo = Literal["prev", "next"]

Cursor = Union[int, Tuple[int, ...]]

Page = Tuple[Optional[Cursor], MoveTo]


class RangeFilter(BaseModel):

    type: Literal["range"] = "range"

    column: Literal["n_heavy", "weight"] = Field(
        ..., description="The column to filter."
    )

    le: Optional[Union[StrictInt, float]] = Field(
        ..., description="The column must be <= this value."
    )
    lt: Optional[Union[StrictInt, float]] = Field(
        ..., description="The column must be < this value."
    )

    ge: Optional[Union[StrictInt, float]] = Field(
        ..., description="The column must be >= this value."
    )
    gt: Optional[Union[StrictInt, float]] = Field(
        ..., description="The column must be > this value."
    )

    @validator("lt", always=True)
    def _lt_mutually_exclusive(cls, v, values):
        if values["le"] and v:
            raise ValueError("lt and le are mututally exclusive.")
        return v

    @validator("gt", always=True)
    def _gt_mutually_exclusive(cls, v, values):
        if values["ge"] and v:
            raise ValueError("gt and ge are mututally exclusive.")
        return v


class SMARTSFilter(BaseModel):

    type: Literal["smarts"] = "smarts"

    smarts: str = Field(..., description="The SMARTS (or SMILES) pattern to filter by.")

    @validator("smarts")
    def _validate_smarts(cls, value: str):
        assert Chem.MolFromSmarts(value) is not None
        return value


class Link(BaseModel):

    self: str = Field(..., description="The API endpoint associated with this object.")
    id: int = Field(..., description="The unique id associated with this object.")


class PaginationLinks(BaseModel):

    self: str = Field(..., description="The API endpoint associated with this object.")

    first: Optional[str] = Field(
        None,
        description="The API endpoint to use to retrieve the first page of items.",
    )
    prev: Optional[str] = Field(
        None,
        description="The API endpoint to use to retrieve the previous page of items.",
    )
    next: Optional[str] = Field(
        None,
        description="The API endpoint to use to retrieve the next page of items.",
    )
    last: Optional[str] = Field(
        None,
        description="The API endpoint to use to retrieve the last page of items.",
    )


class PaginationMetadata(BaseModel):

    cursor: Optional[str] = Field(..., description="The id of the retrieved page.")
    move_to: MoveTo = Field(
        ..., description="The direction in which the page was retrieved"
    )

    per_page: int = Field(..., description="The requested number of items to retrieve.")

    sort_by: Optional[SortBy] = Field(
        ...,
        description="The (optional) column that was sorted by and the direction it was "
        "sorted in.",
    )

    filters: List[Union[SMARTSFilter, RangeFilter]] = Field(
        ..., description="The filters that were applied if any."
    )


class PaginatedCollection(GenericModel, Generic[_T]):

    metadata: PaginationMetadata = Field(
        ..., alias="_metadata", description="Metadata about what page was retrieved."
    )

    links: PaginationLinks = Field(
        ...,
        alias="_links",
        description="API endpoints associated with this collection.",
    )

    contents: List[_T] = Field(..., description="The contents of the collection.")


class GETMoleculeResponse(Link):

    smiles: str = Field(..., description="The SMILES representation of the molecule.")

    links: Dict[str, str] = Field(
        ..., alias="_links", description="API endpoints associated with this response."
    )


class GETMoleculesResponse(PaginatedCollection[GETMoleculeResponse]):
    ...
