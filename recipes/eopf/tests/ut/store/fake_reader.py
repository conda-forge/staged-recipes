from pathlib import Path
from typing import TYPE_CHECKING, Any

from eopf.store.abstract import EOReader
from eopf.store.reader_registry import EOReaderRegistry

if TYPE_CHECKING:  # pragma: no cover
    from xarray import DataTree


@EOReaderRegistry.register("fakereader")
class FakeReader(EOReader):
    EXTENSIONS = ".fake"

    def open_datatree(
        self,
        filename_or_obj: str | Path | Any,
        *,
        chunks: Any = None,
        cache: bool | None = None,
        decode_cf: bool | None = None,
        mask_and_scale: bool | dict[str, bool] | None = None,
        decode_times: bool | Any | None = None,
        decode_timedelta: bool | Any | None = None,
        use_cftime: bool | None = None,
        concat_characters: bool | None = None,
        decode_coords: str | bool | None = None,
        drop_variables: str | list[str] | None = None,
        create_default_indexes: bool = True,
        inline_array: bool = False,
        chunked_array_type: str | None = None,
        from_array_kwargs: dict[str, Any] | None = None,
        backend_kwargs: dict[str, Any] | None = None,
        **kwargs: Any,
    ) -> "DataTree":
        pass

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
