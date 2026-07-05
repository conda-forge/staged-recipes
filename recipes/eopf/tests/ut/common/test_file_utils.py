#
# Copyright (C) 2026 CS Group
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import json
import os
import os.path as osp
import platform
import shutil
from io import BytesIO
import uuid
from pathlib import Path

import pytest
import zarr
from aiohttp import BasicAuth
from kerchunk import hdf

from eopf.common.file_utils import (
    AnyPath,
    any_matching_file_contains_pattern,
    compute_json_size,
    file_md5,
    format_s3_cloud_config,
    is_local_path,
    join_uri,
    load_json_file,
    load_yaml_file,
    local_url_to_path,
    make_absolute_path,
    pattern_missing_in_matching_files,
    replace_text_in_json,
    resolve_storage_options_from_secrets,
    storage_options_to_obstore_config,
)
from eopf.common.functions_utils import change_working_dir, is_serializable
from eopf.common.temp_utils import EOLocalTemporaryFolder
from eopf.common.yaml_codecs import register_yaml_codecs
from eopf.config.secret_providers.file_secret_store import FileSecretStore
from eopf.config.secrets_manager import SecretsManager
from eopf.exceptions import MissingConfigurationParameterError

SAMPLE_OL_1_EFR = "S3A_OL_1_EFR____20231011T123858_20231011T124158_20231011T143747_0179_104_209_2160_PS1_O_NR_003.SEN3"
SAMPLE_OL_1_EFR_zip = (
    "S3A_OL_1_EFR____20231011T123858_20231011T124158_20231011T143747_0179_104_209_2160_PS1_O_NR_003.SEN3.zip"
)
SAMPLE_LEGACY_NOISE = """
<noise>
  <noiseVectorList count="1">
    <noiseVector>
      <noiseLut count="2">2.654077e+02 2.630001e+02
      </noiseLut>
    </noiseVector>
  </noiseVectorList>
</noise>
"""
SAMPLE_NOISE = """
<noise>
  <noiseRangeVectorList count="1">
    <noiseRangeVector>
      <noiseRangeLut count="2">2.654077e+02 2.630001e+02
      </noiseRangeLut>
    </noiseRangeVector>
  </noiseRangeVectorList>
</noise>
"""


@pytest.fixture
def embedbed_test_data_folder_str(EMBEDED_TEST_DATA_FOLDER_UNIT):
    return str(EMBEDED_TEST_DATA_FOLDER_UNIT)


@pytest.fixture
def sample_ol_1_efr() -> str:
    return SAMPLE_OL_1_EFR


@pytest.fixture
def sample_ol_1_efr_zip() -> str:
    return SAMPLE_OL_1_EFR_zip


@pytest.fixture
def stac_extension_schema_url() -> str:
    return "https://cs-si.github.io/eopf-stac-extension/v1.2.0/schema.json"


@pytest.mark.unit
def test_load_yaml_file(embedbed_test_data_folder_str):
    trigger_filename = "trigger.yaml"
    filepath = os.path.join(embedbed_test_data_folder_str, "triggering", trigger_filename)
    load_yaml_file(filepath)
    with pytest.raises(FileNotFoundError):
        load_yaml_file(os.path.join(embedbed_test_data_folder_str, "trigger_not.yaml"))
    with pytest.raises(Exception):
        load_yaml_file(os.path.join(embedbed_test_data_folder_str, "fileutils", "malformed.yaml"))


@pytest.mark.unit
def test_load_yaml_file_supports_aiohttp_basic_auth_codec(tmp_path: Path, monkeypatch: pytest.MonkeyPatch):
    register_yaml_codecs()
    monkeypatch.setenv("BASIC_AUTH_TOKEN", "test-token")
    payload_file = tmp_path / "payload.yaml"
    payload_file.write_text(
        "\n".join(
            [
                "storage_options:",
                "  client_kwargs:",
                "    trust_env: true",
                "    auth: !BasicAuth",
                "      login: ignored",
                "      token: $BASIC_AUTH_TOKEN",
            ],
        ),
        encoding="utf-8",
    )

    payload = load_yaml_file(payload_file)

    auth = payload["storage_options"]["client_kwargs"]["auth"]
    assert isinstance(auth, BasicAuth)
    assert auth.login == "ignored"
    assert auth.password == "test-token"


@pytest.mark.unit
def test_load_json_file(embedbed_test_data_folder_str):
    trigger_filename = "trigger.json"
    filepath = os.path.join(embedbed_test_data_folder_str, "triggering", trigger_filename)
    load_json_file(filepath)
    with pytest.raises(FileNotFoundError):
        load_json_file(os.path.join(embedbed_test_data_folder_str, "trigger_not.json"))
    with pytest.raises(Exception):
        load_json_file(os.path.join(embedbed_test_data_folder_str, "fileutils", "malformed.json"))


@pytest.mark.unit
def test_resolve_storage_options_from_eoconfiguration_non_s3_inputs(tmp_path: Path):
    storage_options = {"anon": True}

    assert resolve_storage_options_from_secrets(tmp_path / "local.json", storage_options) == storage_options
    assert resolve_storage_options_from_secrets(object(), storage_options) == storage_options


@pytest.mark.unit
def test_resolve_storage_options_from_eoconfiguration_keeps_explicit_credentials():
    storage_options = {"key": "explicit-key", "secret": "explicit-secret"}

    assert (
        resolve_storage_options_from_secrets("s3://dpr-cpm-input/cpm/unit_test_data/product", storage_options)
        == storage_options
    )


@pytest.mark.unit
def test_resolve_storage_options_from_secrets_uses_secret_binding(tmp_path: Path):
    SecretsManager.clear()
    secrets_manager = SecretsManager()

    secret_file = tmp_path / "secrets.json"
    secret_file.write_text(
        json.dumps(
            {
                "secret_bindings": {"dpr-cpm-input/cpm/unit_test_data": "test_data"},
                "test_data": {
                    "key": "resolved-key",
                    "secret": "resolved-secret",
                    "client_kwargs": {
                        "endpoint_url": "https://s3.example.test",
                        "region_name": "eu-west-1",
                    },
                },
            },
        ),
        encoding="utf-8",
    )

    try:
        secrets_manager.add_provider(FileSecretStore(secret_file))

        assert resolve_storage_options_from_secrets("s3://dpr-cpm-input/other", None) is None
        assert resolve_storage_options_from_secrets(
            "s3://dpr-cpm-input/cpm/unit_test_data/product",
            {"anon": False},
        ) == {
            "anon": False,
            "key": "resolved-key",
            "secret": "resolved-secret",
            "client_kwargs": {
                "endpoint_url": "https://s3.example.test",
                "region_name": "eu-west-1",
            },
        }
    finally:
        SecretsManager.clear()


@pytest.mark.unit
def test_local_path_helpers(tmp_path: Path):
    plain_path = tmp_path / "data.txt"
    file_url = plain_path.as_uri()

    assert is_local_path(plain_path)
    assert is_local_path(str(plain_path))
    assert is_local_path(file_url)
    assert not is_local_path("s3://bucket/key")

    assert local_url_to_path(file_url) == plain_path
    assert local_url_to_path(str(plain_path)) == plain_path


@pytest.mark.unit
def test_join_uri_for_local_file_and_remote_paths(tmp_path: Path):
    assert join_uri(str(tmp_path), "child.txt") == str(tmp_path / "child.txt")
    assert join_uri(tmp_path.as_uri(), "child.txt") == (tmp_path / "child.txt").as_uri()
    assert join_uri("s3://bucket/prefix/", "child.txt") == "s3://bucket/prefix/child.txt"


@pytest.mark.unit
def test_make_absolute_path_with_current_directory_and_reference(tmp_path: Path):
    cwd_relative = make_absolute_path("relative.txt")
    assert cwd_relative == (Path.cwd() / "relative.txt").absolute()

    ref_dir = tmp_path / "ref_dir"
    ref_dir.mkdir()
    assert make_absolute_path("child.txt", ref_dir) == (ref_dir / "child.txt").absolute()

    ref_file = ref_dir / "config.yaml"
    ref_file.touch()
    assert make_absolute_path("sibling.txt", ref_file) == (ref_dir / "sibling.txt").absolute()

    absolute = tmp_path / "already_absolute.txt"
    assert make_absolute_path(absolute, ref_file) == absolute


@pytest.mark.unit
def test_file_exists(embedbed_test_data_folder_str):
    trigger_filename = "trigger.yaml"
    path_obj = AnyPath(os.path.join(embedbed_test_data_folder_str, "triggering", trigger_filename))
    assert path_obj.exists()
    path_obj = AnyPath(os.path.join(embedbed_test_data_folder_str, "trigger_not.json"))
    assert not path_obj.exists()


@pytest.mark.real_s3
@pytest.mark.parametrize(
    "suffix, result",
    [
        ("olci_zarr_test.zip", True),
        ("olci_zarr_test_not_found.zip", False),
        ("olci_zarr_test.zarr", True),
    ],
    ids=["real_file", "fake_file", "real_dir"],
)
def test_file_exists_s3(
    suffix: str,
    result: bool,
    s3_test_data: tuple[str | None, str],
    s3_config_real: dict,
):
    protocol, base_path = s3_test_data

    if suffix.endswith(".zip"):
        url = f"zip::{protocol}://{base_path}/{suffix}"
    else:
        url = f"{protocol}://{base_path}/{suffix}"

    path_obj = AnyPath(url, **s3_config_real)
    assert path_obj.exists() == result


@pytest.mark.unit
@pytest.mark.real_s3
@pytest.mark.parametrize(
    "suffix, is_zip, result",
    [
        ("olci_zarr_test.zip", True, True),
        ("olci_zarr_test.zarr", False, True),
    ],
    ids=["real_file", "real_dir"],
)
def test_any_path_get_s3(
    suffix: str,
    is_zip: bool,
    result: bool,
    s3_test_data: tuple[str | None, str],
    s3_config_real: dict,
) -> None:
    protocol, base_path = s3_test_data

    if protocol is None:
        raise RuntimeError("S3_TEST_DATA_FOLDER must include a protocol")

    url = f"zip::{protocol}://{base_path}/{suffix}" if is_zip else f"{protocol}://{base_path}/{suffix}"

    EOLocalTemporaryFolder.clear(gc_collect=True)
    path_obj = AnyPath(url, **s3_config_real)
    local_path = path_obj.get(recursive=True)

    assert local_path.exists() is result

    local_tmp: AnyPath = EOLocalTemporaryFolder().get()
    local_tmp.rm(recursive=True)

    with pytest.raises(RuntimeError):
        path_obj.get(recursive=True)

    EOLocalTemporaryFolder.clear(gc_collect=True)


@pytest.mark.unit
@pytest.mark.parametrize(
    "prefix, path, exists, isfile, isdir, size, iscompressed, protocol",
    [
        ("", "triggering/trigger.yaml", True, True, False, 0, False, "local"),
        ("", "trigger_not.json", False, False, False, 0, False, "local"),
        ("", "fileutils", True, False, True, 4, False, "local"),
        ("", "triggggggggering", False, False, False, 0, False, "local"),
        ("", "OLCI_COG_light", True, False, True, 3, False, "local"),
        ("", "fileutils/OLCI_COG_light.zip", True, False, True, 3, True, "zip"),
        ("zip::", "fileutils/OLCI_COG_light.zip", True, False, True, 3, True, "zip"),
    ],
    ids=["real_file", "fake_file", "real_dir", "fake_dir", "olci_dir", "olci_zip", "olci_zip_alt"],
)
def test_any_path_local(
    embedbed_test_data_folder_str,
    prefix,
    path,
    exists,
    isfile,
    isdir,
    size,
    iscompressed,
    protocol,
):
    """
    Unit test for AnyPath wrapper functions
    """

    full_path = prefix + os.path.join(embedbed_test_data_folder_str, path)
    path_obj = AnyPath(full_path)
    assert path_obj.exists() == exists
    assert path_obj.isfile() == isfile
    assert path_obj.isdir() == isdir
    assert len(path_obj) == size
    assert path_obj.sep == "/"
    assert path_obj.is_archive_candidate() == iscompressed
    assert path_obj.protocol == protocol

    ls_out = path_obj.ls()
    assert len(ls_out) == size
    for item in ls_out:
        assert isinstance(item, AnyPath)


@pytest.mark.unit
def test_any_path_explore(embedbed_test_data_folder_str):
    """
    Unit test for directory and archive exploration with AnyPath
    """

    # Directory
    full_path = os.path.join(embedbed_test_data_folder_str, "OLCI_COG_light")
    path_obj = AnyPath(full_path)

    child_obj = path_obj.ls()
    assert len(child_obj) == 3

    root_path = osp.join(osp.abspath(embedbed_test_data_folder_str), "OLCI_COG_light")
    content = []
    for item in child_obj:
        assert os.path.normpath(osp.dirname(str(item))) == os.path.normpath(root_path)
        content.append(osp.basename(osp.realpath(str(item))))

    # Zip archive
    full_path = os.path.join(embedbed_test_data_folder_str, "fileutils", "OLCI_COG_light.zip")
    path_obj = AnyPath(full_path)

    child_obj = path_obj.ls()
    assert len(child_obj) == 3

    content_zip = []
    for item in child_obj:
        content_zip.append(osp.basename(osp.realpath(str(item))))

    assert sorted(content) == sorted(content_zip)


@pytest.mark.unit
def test_any_path_mkdir(OUTPUT_DIR):
    """
    Unit test for AnyPath.mkdir()
    """

    # Directory
    full_path = os.path.join(OUTPUT_DIR, "test_any_path_mkdir")
    if os.path.isdir(full_path):
        shutil.rmtree(full_path)

    # instanciate AnyPath object
    path_obj = AnyPath(full_path)
    assert not path_obj.exists()

    # Create folder, verify it exists
    path_obj.mkdir()
    assert path_obj.isdir()

    # Add 2 sub-folders to current path, and make directories
    child_obj = path_obj / "some" / "subfolder"

    # mkdir should create all folders
    child_obj.mkdir()
    assert child_obj.isdir()

    # mkdir(exist_ok=False) should raise an exception
    with pytest.raises(FileExistsError):
        child_obj.mkdir()

    # mkdir(exist_ok=True) should not raise an exception
    child_obj.mkdir(exist_ok=True)


@pytest.mark.unit
@pytest.mark.real_s3
def test_any_path_mkdir_s3(s3_output_test_data, s3_output_config_real):
    protocol, bucket = s3_output_test_data
    path_obj = AnyPath(f"{protocol}://{bucket}/test_any_path_mkdir_s3", **s3_output_config_real)

    try:
        path_obj.mkdir(exist_ok=True)
        assert path_obj.exists()
        assert (path_obj / ".keep").exists()
    finally:
        path_obj.rm(recursive=True)


@pytest.mark.unit
def test_any_path_find(embedbed_test_data_folder_str):
    """
    Unit test for AnyPath.find()
    """

    # Directory
    full_path = osp.realpath(osp.join(embedbed_test_data_folder_str, "OLCI_COG_light"))
    path_obj = AnyPath(full_path) / "coordinates"

    results = path_obj.find()
    assert len(results) == 5
    assert isinstance(results[0], AnyPath)
    results_str = sorted([str(item) for item in results])
    ref_str = [
        osp.join("coordinates", "orphans", "detector_index.nc"),
        osp.join("coordinates", "orphans", "latitude.nc"),
        osp.join("coordinates", "orphans", "longitude.nc"),
        osp.join("coordinates", "tiepoint_grid", "latitude.nc"),
        osp.join("coordinates", "tiepoint_grid", "longitude.nc"),
    ]
    for item, ref in zip(results_str, ref_str):
        assert os.path.normpath(item) == os.path.normpath(full_path + "/" + ref)

    # Dir with regex
    results = path_obj.find(regex="[a-z]+/.*tude.nc")
    assert len(results) == 2
    results_str = sorted([str(item) for item in results])
    ref_regex_str = [
        osp.join("coordinates", "orphans", "latitude.nc"),
        osp.join("coordinates", "orphans", "longitude.nc"),
    ]
    for item, ref in zip(results_str, ref_regex_str):
        assert os.path.normpath(item) == os.path.normpath(full_path + "/" + ref)

    # Zip archive
    full_path = osp.join(embedbed_test_data_folder_str, "fileutils", "OLCI_COG_light.zip")
    path_obj = AnyPath(full_path) / "coordinates"

    results = path_obj.find()
    assert len(results) == 5
    assert isinstance(results[0], AnyPath)
    results_str = sorted([str(item) for item in results])

    for item, ref in zip(results_str, ref_str):
        assert os.path.normpath(item) == os.path.normpath("OLCI_COG_light/" + ref)

    # Zip with regex
    results = path_obj.find(regex="[a-z]+/.*tude\\.nc")
    assert len(results) == 2
    results_str = sorted([str(item) for item in results])
    for item, ref in zip(results_str, ref_regex_str):
        assert os.path.normpath(item) == os.path.normpath("OLCI_COG_light/" + ref)


@pytest.mark.unit
def test_any_path_find_dot_in_path(embedbed_test_data_folder_str):
    # Directory
    full_path = embedbed_test_data_folder_str + "/./" + "OLCI_COG_light"
    path_obj = AnyPath.cast(full_path)

    assert len(path_obj.find(".*.nc")) != 0


@pytest.mark.unit
def test_any_path_find_relative(embedbed_test_data_folder_str):
    with change_working_dir(embedbed_test_data_folder_str):
        # Directory
        full_path = "./" + "OLCI_COG_light"
        path_obj = AnyPath(full_path)
        assert len(path_obj.find(".*.nc")) != 0


@pytest.mark.unit
@pytest.mark.real_s3
def test_any_path_find_remote(s3_test_data, s3_config_real, sample_ol_1_efr):
    full_path = os.path.join(f"{s3_test_data[0]}://{s3_test_data[1]}", sample_ol_1_efr)
    path_obj = AnyPath(full_path, **s3_config_real)

    results = path_obj.find(r".*/Oa12_.*\.nc")

    assert len(results) == 2
    assert all(isinstance(result, AnyPath) for result in results)
    assert sorted(result.basename for result in results) == ["Oa12_radiance.nc", "Oa12_radiance_unc.nc"]


@pytest.mark.unit
def test_any_path_glob(embedbed_test_data_folder_str):
    """
    Unit test for AnyPath.glob()
    """

    # Directory
    full_path = osp.realpath(osp.join(embedbed_test_data_folder_str, "OLCI_COG_light"))
    path_obj = AnyPath(full_path)

    results = path_obj.glob("**/longitude.nc")
    assert len(results) == 2
    assert isinstance(results[0], AnyPath)
    results_str = sorted([str(item) for item in results])
    ref_str = [
        osp.join("coordinates", "orphans", "longitude.nc"),
        osp.join("coordinates", "tiepoint_grid", "longitude.nc"),
    ]
    for item, ref in zip(results_str, ref_str):
        assert os.path.normpath(item) == os.path.normpath(full_path + "/" + ref)

    # Zip archive
    full_path = osp.join(embedbed_test_data_folder_str, "fileutils", "OLCI_COG_light.zip")
    path_obj = AnyPath(full_path)
    results = path_obj.glob("**/longitude.nc")
    assert len(results) == 2
    assert isinstance(results[0], AnyPath)
    results_str = sorted([str(item) for item in results])
    for item, ref in zip(results_str, ref_str):
        assert os.path.normpath(item) == os.path.normpath("OLCI_COG_light/" + ref)


@pytest.mark.unit
def test_any_path_glob_zips(embedbed_test_data_folder_str):
    """
    Unit test for AnyPath.glob()
    """

    # zips in folder
    full_path = osp.realpath(osp.join(embedbed_test_data_folder_str, "zips"))
    path_obj = AnyPath(full_path)

    results = path_obj.glob("*")
    assert len(results) == 2
    assert isinstance(results[0], AnyPath)
    assert isinstance(results[0].parent, AnyPath)
    assert results[0].protocol == "zip"

    results_str = sorted([str(item) for item in results])
    ref_str = [
        osp.join("test2.txt"),
        osp.join("try.txt"),
    ]
    for item, ref in zip(results_str, ref_str):
        assert os.path.normpath(item) == os.path.normpath(ref)


@pytest.mark.unit
@pytest.mark.parametrize(
    "base, rhs, expected",
    [
        ("a", "b", "a/b"),
        ("a/", "b", "a/b"),
        ("a", "b/", "a/b/"),
        ("a/", "b/", "a/b/"),
        ("/a", "b", "/a/b"),
        ("/a/", "b", "/a/b"),
        ("/a", "b/c", "/a/b/c"),
        ("a/b", "c", "a/b/c"),
        ("/a/b", "/a/c", "/a/c"),
    ],
)
def test_anypath_truediv_basic_joins(base: str, rhs: str, expected: str):
    out = AnyPath(base) / rhs
    assert str(out) == expected


@pytest.mark.unit
def test_anypath_truediv_chain_joins():
    out = AnyPath("root") / "a" / "b" / "file.nc"
    assert str(out) == "root/a/b/file.nc"


@pytest.mark.unit
def test_anypath_truediv_with_absolute_rhs_overrides_base_if_supported():
    """
    Many path implementations treat an absolute RHS as overriding the base:
      AnyPath("a/b") / "/c" -> "/c"
    If your AnyPath intentionally behaves differently, change the expectation.
    """
    out = AnyPath("a/b") / "/c"
    assert str(out) == "/c"


@pytest.mark.unit
@pytest.mark.parametrize(
    "rhs",
    [""],
)
def test_anypath_truediv_ignores_empty_rhs(rhs):
    """
    If your AnyPath ignores empty RHS, this should hold.
    If you prefer it to raise, change this test accordingly.
    """
    base = AnyPath("a/b")
    out = base / rhs  # type: ignore[operator]
    assert str(out) == "a/b"


@pytest.mark.unit
@pytest.mark.parametrize(
    "rhs, expected_exc",
    [
        (None, TypeError),
        (123, TypeError),
        (object(), TypeError),
    ],
)
def test_anypath_truediv_error_cases(rhs, expected_exc):
    with pytest.raises(expected_exc):
        _ = AnyPath("a/b") / rhs  # type: ignore[operator]


@pytest.mark.unit
def test_anypath_truediv_preserves_trailing_slash_from_base_when_joining():
    """
    Decide your contract here. Most joiners normalize "a/" + "b" -> "a/b".
    This test asserts normalization (no double slashes).
    """
    out = AnyPath("a///") / "b"
    assert str(out) == "a/b"


@pytest.mark.unit
def test_any_path_open(embedbed_test_data_folder_str):
    """
    Unit test for AnyPath.open()
    """

    # Directory
    full_path = osp.realpath(osp.join(embedbed_test_data_folder_str, "OLCI_COG_light", "attrs.json"))
    path_obj = AnyPath(full_path)

    with path_obj.open() as file_obj:
        data = json.load(file_obj)

    with open(full_path, "r", encoding="utf-8") as file_obj:
        ref_data = json.load(file_obj)

    assert data == ref_data

    # Zip archive
    full_path = osp.join(embedbed_test_data_folder_str, "fileutils", "OLCI_COG_light.zip")
    path_obj = AnyPath(full_path) / "attrs.json"
    with path_obj.open() as file_obj:
        data = json.load(file_obj)

    assert data == ref_data


def test_any_path_touch(OUTPUT_DIR):
    """
    unit test for AnyPath.touch
    Parameters
    ----------
    OUTPUT_DIR

    Returns
    -------

    """
    # file
    full_path = os.path.join(OUTPUT_DIR, "test_any_path_touch.zip")
    if os.path.exists(full_path):
        shutil.rmtree(full_path)

    # instanciate AnyPath object
    path_obj = AnyPath(full_path)
    assert not path_obj.exists()

    # touch it
    path_obj.touch()
    assert path_obj.exists()


@pytest.mark.unit
def test_any_path_cat(embedbed_test_data_folder_str):
    """
    Unit test for AnyPath.cat()
    """

    # Directory
    full_path = osp.realpath(osp.join(embedbed_test_data_folder_str, "OLCI_COG_light", "attrs.json"))
    path_obj = AnyPath(full_path)

    data = path_obj.cat()

    with open(full_path, "rb") as file_obj:
        ref_data = file_obj.read()

    assert data == ref_data

# TBD correct cat from archives and uncomment this part, see issue 1124
#    # Zip archive
#    full_path = osp.join(embedbed_test_data_folder_str, "fileutils", "OLCI_COG_light.zip")
#    path_obj = AnyPath(full_path) / "attrs.json"
#    data = path_obj.cat()
#
#    if platform.system() == "Windows":
#        ref_data = ref_data.rstrip(b"\r\n")
#    else:
#        ref_data = ref_data.rstrip(b"\n")
#
#    assert data == ref_data


@pytest.mark.unit
@pytest.mark.real_s3
@pytest.mark.parametrize(
    "path, auto_zip, exists, isfile, isdir, size, iscompressed, protocol",
    [
        ("test_product.SAFE.zip", False, True, True, False, 0, False, "s3"),
        ("dead_product.zip", True, False, False, False, 0, False, "s3"),
        ("test_product.SAFE", True, True, False, True, 6, False, "s3"),
        ("dead_product.SAFE", True, False, False, False, 0, False, "s3"),
        (SAMPLE_OL_1_EFR_zip, True, True, False, True, 52, True, "zip"),
    ],
    ids=["real_file", "fake_file", "real_dir", "fake_dir", "olci_zip"],
)
def test_any_path_remote(
    path,
    auto_zip,
    exists,
    isfile,
    isdir,
    size,
    iscompressed,
    protocol,
    s3_test_data,
    s3_config_real,
):
    """
    Unit test for AnyPath wrapper functions
    """

    full_path = os.path.join(f"{s3_test_data[0]}://{s3_test_data[1]}", path)
    path_obj = AnyPath(full_path, auto_open_archives=auto_zip, **s3_config_real)
    assert path_obj.exists() == exists
    assert path_obj.isfile() == isfile
    assert path_obj.isdir() == isdir
    assert len(path_obj) == size
    assert path_obj.sep == "/"
    assert path_obj.is_archive_candidate() == iscompressed
    assert path_obj.protocol == protocol

    ls_out = path_obj.ls()
    assert len(ls_out) == size
    for item in ls_out:
        assert isinstance(item, AnyPath)


@pytest.mark.unit
@pytest.mark.real_s3
def test_any_path_glob_remote(s3_test_data, s3_config_real):
    """
    Unit test for AnyPath.glob() on remote filesystem
    """

    full_path = os.path.join(f"{s3_test_data[0]}://{s3_test_data[1]}", SAMPLE_OL_1_EFR_zip)
    path_obj = AnyPath(full_path, **s3_config_real)

    results = path_obj.glob("Oa12_*.nc")
    assert len(results) == 2
    assert isinstance(results[0], AnyPath)


@pytest.mark.unit
@pytest.mark.real_s3
def test_any_path_glob_remote_url_has_no_duplicate_prefix(s3_test_data, s3_config_real, sample_ol_1_efr_zip):
    """
    Regression test for fsspec/s3fs glob results already being bucket-qualified.
    """

    full_path = os.path.join(f"{s3_test_data[0]}://{s3_test_data[1]}", sample_ol_1_efr_zip)
    path_obj = AnyPath(full_path, **s3_config_real)

    results = path_obj.glob("Oa12_*.nc")

    assert len(results) == 2
    for result in results:
        print(repr(result))
        assert result.url.startswith(f"{s3_test_data[0]}://{s3_test_data[1]}/{sample_ol_1_efr_zip}/")
        assert result.url.endswith(result.basename)
        assert f"{sample_ol_1_efr_zip}/{s3_test_data[1]}/" not in result.url


@pytest.mark.unit
@pytest.mark.real_s3
def test_any_path_find_remote_url_has_no_duplicate_prefix(s3_test_data, s3_config_real, sample_ol_1_efr_zip):
    """
    Regression test for fsspec/s3fs find results already being bucket-qualified.
    """

    full_path = os.path.join(f"{s3_test_data[0]}://{s3_test_data[1]}", sample_ol_1_efr_zip)
    path_obj = AnyPath(full_path, **s3_config_real)

    results = path_obj.find(r".*/Oa12_.*\.nc")

    assert len(results) == 2
    for result in results:
        assert result.url.startswith(f"{s3_test_data[0]}://{s3_test_data[1]}/{sample_ol_1_efr_zip}/")
        assert result.url.endswith(result.basename)
        assert f"{sample_ol_1_efr_zip}/{s3_test_data[1]}/" not in result.url


@pytest.mark.unit
@pytest.mark.parametrize(
    "returned_fs_path",
    [
        "dpr-cpm-input/cpm/unit_test_data/"
        "S3A_OL_1_EFR____20231011T123858_20231011T124158_20231011T143747_0179_104_209_2160_PS1_O_NR_003.SEN3/"
        "Oa12_radiance.nc",
        "cpm/unit_test_data/"
        "S3A_OL_1_EFR____20231011T123858_20231011T124158_20231011T143747_0179_104_209_2160_PS1_O_NR_003.SEN3/"
        "Oa12_radiance.nc",
    ],
)
def test_any_path_s3_fs_path_to_url_handles_bucket_qualified_and_relative_paths(returned_fs_path):
    """
    S3 paths returned by fsspec are exposed as canonical user-facing s3:// URLs.
    """
    product = "S3A_OL_1_EFR____20231011T123858_20231011T124158_20231011T143747_0179_104_209_2160_PS1_O_NR_003.SEN3"
    path_obj = AnyPath(f"s3://dpr-cpm-input/cpm/unit_test_data/{product}", anon=True)

    assert (
        path_obj._fs_path_to_url(returned_fs_path)
        == f"s3://dpr-cpm-input/cpm/unit_test_data/{product}/Oa12_radiance.nc"
    )
    assert (
        path_obj._url_to_fs_path(path_obj._fs_path_to_url(returned_fs_path))
        == f"dpr-cpm-input/cpm/unit_test_data/{product}/Oa12_radiance.nc"
    )


@pytest.mark.unit
def test_any_path_s3_fs_path_normalization_keeps_empty_path_empty():
    """
    Empty S3 child paths stay empty instead of expanding to the current base path.
    """
    path_obj = AnyPath("s3://dpr-cpm-input/cpm/unit_test_data/embedbed/rasterio", anon=True)

    assert path_obj._path_model.normalize_s3_fs_path("") == ""
    assert path_obj._path_model.normalize_s3_fs_path("/") == ""


@pytest.mark.unit
@pytest.mark.parametrize(
    "returned_fs_path",
    [
        "dpr-cpm-input/cpm/unit_test_data/"
        "S3A_OL_1_EFR____20231011T123858_20231011T124158_20231011T143747_0179_104_209_2160_PS1_O_NR_003.SEN3/"
        "Oa12_radiance.nc",
        "cpm/unit_test_data/"
        "S3A_OL_1_EFR____20231011T123858_20231011T124158_20231011T143747_0179_104_209_2160_PS1_O_NR_003.SEN3/"
        "Oa12_radiance.nc",
    ],
)
def test_any_path_find_s3_matches_immediate_children_from_bucket_qualified_and_relative_paths(
    monkeypatch,
    returned_fs_path,
):
    """
    S3 find results match immediate child files whether fsspec returns bucket-qualified or relative paths.
    """
    product = "S3A_OL_1_EFR____20231011T123858_20231011T124158_20231011T143747_0179_104_209_2160_PS1_O_NR_003.SEN3"
    path_obj = AnyPath(f"s3://dpr-cpm-input/cpm/unit_test_data/{product}", anon=True)
    monkeypatch.setattr(path_obj.fs, "find", lambda _, **__: [returned_fs_path])

    results = path_obj.find(r".*/Oa12_.*\.nc")

    assert len(results) == 1
    assert results[0].url == f"s3://dpr-cpm-input/cpm/unit_test_data/{product}/Oa12_radiance.nc"


@pytest.mark.unit
def test_any_path_s3_fs_path_to_url_handles_relative_paths_from_wildcard_base():
    """
    Relative S3 children from wildcard bases are resolved under the non-wildcard prefix.
    """
    path_obj = AnyPath("s3://dpr-cpm-input/cpm/unit_test_data/embedbed/rasterio/*.jp2", anon=True)

    assert (
        path_obj._path_model.normalize_s3_fs_path("small_raster.jp2")
        == "dpr-cpm-input/cpm/unit_test_data/embedbed/rasterio/small_raster.jp2"
    )
    assert (
        path_obj._fs_path_to_url("small_raster.jp2")
        == "s3://dpr-cpm-input/cpm/unit_test_data/embedbed/rasterio/small_raster.jp2"
    )


@pytest.mark.unit
def test_any_path_s3_dirname_keeps_url_and_fs_path_aligned():
    """
    dirname() keeps S3 filesystem paths and user-facing URLs pointed at the same prefix.
    """
    path_obj = AnyPath("s3://dpr-cpm-input/cpm/unit_test_data/embedbed/rasterio/*.jp2", anon=True)

    dirname = path_obj.dirname()

    assert dirname.fs_path == "dpr-cpm-input/cpm/unit_test_data/embedbed/rasterio"
    assert dirname.url == "s3://dpr-cpm-input/cpm/unit_test_data/embedbed/rasterio"


@pytest.mark.unit
@pytest.mark.parametrize(
    "path",
    [
        "s3://bucket/key",
        "file:///tmp/data.json",
        "http://example.test/data.json",
        "https://example.test/data.json",
    ],
)
def test_any_path_fs_path_to_url_keeps_already_protocol_qualified_paths(path):
    """
    Already qualified URLs are returned unchanged regardless of the current filesystem.
    """
    path_obj = AnyPath("base/path")

    assert path_obj._fs_path_to_url(path) == path


@pytest.mark.unit
@pytest.mark.parametrize("protocol", ["http", "https"])
def test_any_path_http_fs_path_url_roundtrip(protocol):
    """
    HTTP(S) URL conversion preserves the original scheme and keeps URLs filesystem-ready.
    """
    path_obj = AnyPath(f"{protocol}://example.test/base/data.json")

    assert path_obj._fs_path_to_url("example.test/base/child.json") == f"{protocol}://example.test/base/child.json"
    assert path_obj._fs_path_to_url(f"{protocol}://example.test/base/child.json") == (
        f"{protocol}://example.test/base/child.json"
    )
    assert path_obj._url_to_fs_path(f"{protocol}://example.test/base/child.json") == (
        f"{protocol}://example.test/base/child.json"
    )


@pytest.mark.unit
def test_any_path_http_fs_path_url_roundtrip_preserves_query_and_fragment():
    """
    HTTP(S) URL conversion preserves query strings and fragments on already qualified URLs.
    """
    path_obj = AnyPath("https://example.test/base/data.json?token=abc#section")

    assert path_obj._fs_path_to_url("example.test/base/child.json?token=abc") == (
        "https://example.test/base/child.json?token=abc"
    )
    assert path_obj._fs_path_to_url("https://example.test/base/child.json?token=abc#section") == (
        "https://example.test/base/child.json?token=abc#section"
    )
    assert path_obj._url_to_fs_path("https://example.test/base/child.json?token=abc#section") == (
        "https://example.test/base/child.json?token=abc#section"
    )


@pytest.mark.unit
def test_any_path_file_url_uses_local_filesystem(tmp_path: Path):
    """
    file:// inputs are handled as local filesystem resources while preserving accepted file URLs.
    """
    source = tmp_path / "schema.json"
    source.write_text('{"title": "local"}', encoding="utf-8")
    path_obj = AnyPath(source.as_uri())

    assert path_obj.protocol == "local"
    assert path_obj.exists()
    assert path_obj.fs.exists(path_obj._url_to_fs_path(path_obj.url))
    assert path_obj._fs_path_to_url(path_obj.fs_path) == path_obj.fs_path
    with path_obj.open("r") as file_obj:
        assert json.load(file_obj) == {"title": "local"}


@pytest.mark.unit
def test_any_path_fs_path_to_url_keeps_local_absolute_path(tmp_path: Path):
    """
    Local absolute filesystem paths are not joined again to the AnyPath base URL.
    """
    path_obj = AnyPath(str(tmp_path))
    absolute_child = str(tmp_path / "child.json")

    assert path_obj._fs_path_to_url(absolute_child) == absolute_child


@pytest.mark.unit
def test_any_path_fs_path_to_url_joins_relative_non_s3_path():
    """
    Relative non-S3 child paths are exposed below the current user-facing base URL.
    """
    path_obj = AnyPath("base/path")

    assert path_obj._fs_path_to_url("child.json") == "base/path/child.json"
    assert path_obj._url_to_fs_path("base/path/child.json") == "base/path/child.json"


@pytest.mark.unit
@pytest.mark.real_s3
def test_any_path_zip_s3_child_url_preserves_archive_protocol_stack(s3_test_data, s3_config_real):
    """
    zip::s3 archive children keep the archive protocol stack in their user-facing URL.
    """
    protocol, base_path = s3_test_data
    archive_url = f"zip::{protocol}://{base_path}/{SAMPLE_OL_1_EFR_zip}"
    path_obj = AnyPath(archive_url, **s3_config_real)

    child = path_obj / "Oa12_radiance.nc"

    assert path_obj.protocol_list() == ["zip", "s3"]
    assert child.fs_path.endswith("Oa12_radiance.nc")
    assert child.url == f"{archive_url}/Oa12_radiance.nc"


@pytest.mark.unit
@pytest.mark.parametrize(
    "path, basename",
    [
        ("foo/bar", "bar"),
        ("foo/bar/", "bar"),
        ("foo/some_archive.zip", "some_archive.zip"),
        ("/", ""),
        (".", ""),
        ("s3://foo/bar", "bar"),
    ],
    ids=["dir", "trailing_slash", "zip", "root", "dot", "s3_dir"],
)
def test_any_path_basename(path, basename):
    """
    Unit test for AnyPath.basename
    """
    path_obj = AnyPath(path)
    assert path_obj.basename == basename


@pytest.mark.unit
@pytest.mark.parametrize(
    "path, suffix",
    [
        ("foo/bar", ""),
        ("foo/bar/", ""),
        ("foo/some_archive.zip", ".zip"),
        ("foo/some_archive.tar.gz", ".gz"),
        ("/", ""),
        (".", ""),
        ("s3://foo/bar.json", ".json"),
        ("foo/bar/.git", ""),
        ("foo/bar.", ""),
    ],
    ids=["dir", "trailing_slash", "zip", "tar.gz", "root", "dot", "s3_dir", "hidden", "trailing_dot"],
)
def test_any_path_suffix(path, suffix):
    """
    Unit test for AnyPath.suffix
    """
    path_obj = AnyPath(path)
    assert path_obj.suffix == suffix


@pytest.mark.unit
@pytest.mark.parametrize(
    "path, suffixes",
    [
        ("foo/bar", []),
        ("foo/bar/", []),
        ("foo/some_archive.zip", [".zip"]),
        ("foo/some_archive.tar.gz", [".tar", ".gz"]),
        ("/", []),
        (".", []),
        ("s3://foo/bar.json", [".json"]),
        ("foo/bar/.git", []),
        ("foo/bar.", []),
    ],
    ids=["dir", "trailing_slash", "zip", "tar.gz", "root", "dot", "s3_dir", "hidden", "trailing_dot"],
)
def test_any_path_suffixes(path, suffixes):
    """
    Unit test for AnyPath.suffixes
    """
    path_obj = AnyPath(path)
    assert path_obj.suffixes == suffixes


@pytest.mark.unit
@pytest.mark.parametrize(
    "base, path, relpath",
    [
        ("foo/bar", "foo/bar/file.txt", "file.txt"),
        ("foo", "foo/bar/file.txt", "bar/file.txt"),
        ("/foo/bar", "/foo/bar/file.txt", "file.txt"),
        ("/foo", "/foo/bar/file.txt", "bar/file.txt"),
        ("foo/bar", "foo/other/file.txt", "../other/file.txt"),
    ],
    ids=["ex1", "ex2", "ex3", "ex4", "parent"],
)
def test_any_path_relpath(base, path, relpath):
    """
    Unit test for AnyPath.relpath()
    """
    root = AnyPath(base)
    current = AnyPath(path)

    assert os.path.normpath(current.relpath(root)) == os.path.normpath(relpath)


@pytest.mark.unit
@pytest.mark.parametrize(
    "ref, path, abspath",
    [
        ("foo/bar", "./file.txt", "foo/bar/file.txt"),
        ("foo", "/foo/bar/file.txt", "/foo/bar/file.txt"),
        ("/foo/bar/", "../file.txt", "/foo/file.txt"),
        (None, "../file.txt", str(Path(os.path.join(os.getcwd(), "../file.txt")).resolve())),
    ],
)
def test_any_path_make_absolute(ref, path, abspath):
    """
    Unit test for AnyPath.make_absolute()
    """
    ref_any = AnyPath(ref) if ref is not None else None
    current = AnyPath(path)

    assert current.make_absolute(ref_any).fs_path == abspath


@pytest.mark.unit
def test_any_path_get(embedbed_test_data_folder_str):
    """
    Unit test for AnyPath.get()
    """
    # Local file will not call get()
    full_path = osp.realpath(osp.join(embedbed_test_data_folder_str, "OLCI_COG_light", "attrs.json"))
    path_obj = AnyPath(full_path)

    local_path = path_obj.get()
    assert local_path == path_obj.fs_path

    with open(full_path, "rb") as file_obj:
        ref_data = file_obj.read()

# TBD fix cat under zip archives and then uncomment this, see issue 1124
#    # Zip archive a file
#    full_path = osp.join(embedbed_test_data_folder_str, "fileutils", "OLCI_COG_light.zip")
#    path_obj = AnyPath(full_path) / "attrs.json"
#    local_path_dir = path_obj.get()
#    local_path_file = local_path_dir / "attrs.json"
#    with local_path_file.open("rb") as file_obj:
#        data = file_obj.read()
#
#    if platform.system() == "Windows":
#        ref_data = ref_data.rstrip(b"\r\n")
#    else:
#        ref_data = ref_data.rstrip(b"\n")
#    assert data == ref_data
#
#    # Zip archive full
#    full_path = osp.join(embedbed_test_data_folder_str, "fileutils", "OLCI_COG_light.zip")
#    path_obj = AnyPath(full_path)
#    local_path = path_obj.get(recursive=True)
#    print(local_path)
#    print(local_path.glob("*"))
#
#    # Missing file in Zip archive
#    path_obj = AnyPath(full_path) / "this_file_doesnt_exist.txt"
#    with pytest.raises(FileNotFoundError):
#        local_path = path_obj.get()


@pytest.mark.unit
def test_any_path_reference(embedbed_test_data_folder_str):
    """
    Unit test for a NetCDF file opened with kerchunk ("reference" filesystem)
    """

    full_path = osp.join(embedbed_test_data_folder_str, "accessor", "netcdf", "S3B_SL_1_RBT____20230824T091058_cartesian_an.nc")
    first_obj = AnyPath(full_path)
    with first_obj.open() as nc_file:
        zarr_compatible_data = hdf.SingleHdf5ToZarr(nc_file, first_obj.fs_path).translate()

    path_obj = AnyPath("reference://", parent=first_obj, fo=zarr_compatible_data)
    assert path_obj.protocol == "reference"
    ds = zarr.open(path_obj.to_zarr_store())
    assert isinstance(ds["x_an"], zarr.Array)


@pytest.mark.unit
def test_any_path_to_zarr_store_local(tmp_path: Path):
    """
    Local paths produce a zarr local store rooted at the requested filesystem path.
    """
    path_obj = AnyPath(str(tmp_path / "local.zarr"))

    store = path_obj.to_zarr_store()

    assert type(store).__name__ == "LocalStore"
    assert str(store).endswith("/local.zarr")


@pytest.mark.unit
@pytest.mark.real_s3
def test_any_path_to_zarr_store_s3(s3_test_data, s3_config_real):
    """
    S3 zarr paths produce a remote zarr store that can be opened by zarr.
    """
    from zarr.storage import FsspecStore, ObjectStore

    protocol, base_path = s3_test_data
    path_obj = AnyPath(f"{protocol}://{base_path}/olci_zarr_test.zarr", **s3_config_real)

    store = path_obj.to_zarr_store()

    assert isinstance(store, (FsspecStore, ObjectStore))
    assert zarr.open(store, mode="r")


@pytest.mark.unit
def test_any_path_to_zarr_store_s3_uses_obstore_when_requested():
    from zarr.storage import ObjectStore

    path_obj = AnyPath(
        "s3://bucket/product.zarr",
        key="access",
        secret="secret",
        client_kwargs={"endpoint_url": "https://s3.example.com", "region_name": "eu-west-1"},
    )

    store = path_obj.to_zarr_store(use_obstore=True)

    assert isinstance(store, ObjectStore)


@pytest.mark.unit
@pytest.mark.parametrize("protocol", ["http", "https"])
def test_any_path_open_and_get_http(protocol, stac_extension_schema_url):
    """
    HTTP(S) paths can be read directly and downloaded to the local temporary cache.
    """
    url = stac_extension_schema_url.replace("https://", f"{protocol}://", 1)
    path_obj = AnyPath(url)

    with path_obj.open("r") as file_obj:
        opened_schema = json.load(file_obj)

    local_path = path_obj.get()
    with local_path.open("r") as file_obj:
        downloaded_schema = json.load(file_obj)

    assert opened_schema["title"] == "eopf extension for STAC"
    assert downloaded_schema == opened_schema


@pytest.mark.unit
def test_any_path_get_url_and_params():
    local_path = AnyPath("local/path")
    assert local_path.get_url_and_params() == ("local/path", {})

    s3_path = AnyPath("s3://bucket/key", anon=True, client_kwargs={"endpoint_url": "https://s3.example.test"})
    assert s3_path.get_url_and_params() == (
        "s3://bucket/key",
        {"storage_options": {"anon": True, "client_kwargs": {"endpoint_url": "https://s3.example.test"}}},
    )


@pytest.mark.unit
def test_any_path_get_size_and_number_of_files(tmp_path: Path):
    first = tmp_path / "first.txt"
    second_dir = tmp_path / "nested"
    second_dir.mkdir()
    second = second_dir / "second.txt"
    first.write_text("abc", encoding="utf-8")
    second.write_text("12345", encoding="utf-8")

    file_path = AnyPath(str(first))
    dir_path = AnyPath(str(tmp_path))

    assert file_path.get_size() == 3
    assert dir_path.get_size() == 8
    assert dir_path.get_number_of_files() == 2
    with pytest.raises(NotADirectoryError):
        file_path.get_number_of_files()


@pytest.mark.unit
def test_any_path_equals():
    """
    Unit test for __eq__ operator
    """

    path_a = AnyPath("eopf")
    path_b = AnyPath("eopf") / "common"
    path_c = path_a / "common"
    path_d = path_c.copy()

    assert path_a != path_b
    assert path_b == path_c
    assert path_d == path_c
    assert path_b == path_b


@pytest.mark.unit
def test_any_path_dirname(embedbed_test_data_folder_str):
    """
    Unit test for AnyPath.dirname
    """
    cwd = os.getcwd()

    # Local filesystem
    path_a = AnyPath("eopf")
    path_b = AnyPath("eopf/common")
    path_c = AnyPath("/")
    path_d = AnyPath("./eopf")

    dir_b = path_b.dirname()
    assert isinstance(dir_b, AnyPath)
    assert dir_b.fs_path == path_a.fs_path

    dir_c = path_c.dirname()
    if platform.system() == "Windows" and dir_c.fs_path == "/" and path_c.fs_path == "C:":
        path_c._set_path_model(fs_path="/")
    assert dir_c.fs_path == path_c.fs_path

    dir_d = path_d.dirname().absolute
    dir_dir_d = dir_d.dirname()
    assert dir_d.absolute.fs_path == os.path.normpath(cwd)
    assert dir_dir_d.absolute.fs_path == os.path.normpath(osp.dirname(cwd))

    # Zip filesystem
    full_path = osp.join(embedbed_test_data_folder_str, "fileutils", "OLCI_COG_light.zip")
    path_obj = AnyPath(full_path) / "attrs.json"

    dir_obj = path_obj.dirname()
    dir_dir_obj = dir_obj.dirname()

    assert path_obj.fs_path == "OLCI_COG_light/attrs.json"
    assert dir_obj.fs_path == "OLCI_COG_light"
    assert dir_dir_obj.fs_path == ""


@pytest.mark.unit
def test_any_path_in_dict():
    """
    Unit test to check we can put AnyPath in a dict
    """

    mapping = {
        AnyPath("eopf"): 1,
        AnyPath("eopf/common"): 2,
    }

    assert len(mapping) == 2


@pytest.mark.unit
def test_any_path_sort(embedbed_test_data_folder_str):
    """
    Unit test to check we can sort AnyPath
    """

    path_a = AnyPath("eopf")
    path_b = AnyPath("eopf/common")
    path_c = AnyPath("eopf/store")
    path_d = AnyPath("tests")
    path_e = AnyPath(osp.join(embedbed_test_data_folder_str, "fileutils", "OLCI_COG_light.zip"))

    sorted_list = sorted([path_d, path_e, path_b, path_c, path_a])

    assert sorted_list[0] == path_a
    assert sorted_list[1] == path_b
    assert sorted_list[2] == path_c
    assert sorted_list[3] == path_d
    assert sorted_list[4] == path_e

    sorted_list = sorted([path_a, path_c, path_e, path_d, path_b])

    assert sorted_list[0] == path_a
    assert sorted_list[1] == path_b
    assert sorted_list[2] == path_c
    assert sorted_list[3] == path_d
    assert sorted_list[4] == path_e


@pytest.mark.unit
def test_any_path_info(embedbed_test_data_folder_str):
    """
    Unit test for AnyPath.info()
    """

    full_path = osp.join(embedbed_test_data_folder_str, "accessor", "netcdf", "S3B_SL_1_RBT____20230824T091058_cartesian_an.nc")
    path_obj = AnyPath(full_path)

    info = path_obj.info()

    assert "name" in info
    assert "size" in info


@pytest.mark.unit
@pytest.mark.real_s3
@pytest.mark.parametrize(
    "raw_path, use_real_s3_options, protocols",
    [
        ("foo/bar/file.txt", False, ["local"]),
        ("s3://bucket/data", False, ["s3"]),
        ("s3:bucket/data", False, ["s3"]),
        ("embedbed_test_data_folder_str/fileutils/OLCI_COG_light.zip", False, ["zip", "local"]),
        ("S3_TEST_DATA_FOLDER/" + SAMPLE_OL_1_EFR_zip, True, ["zip", "s3"]),
        ("zip::S3_TEST_DATA_FOLDER/" + SAMPLE_OL_1_EFR_zip, True, ["zip", "s3"]),
    ],
    ids=["file", "s3", "s3_short", "zip", "zip_s3", "zip::s3"],
)
def test_any_path_protocol_list(
    raw_path: str,
    use_real_s3_options: bool,
    protocols: list[str],
    embedbed_test_data_folder_str: str,
    s3_test_data: tuple[str | None, str],
    s3_config_real: dict,
) -> None:
    """
    Unit test for AnyPath.protocol_list()
    """
    protocol, base_path = s3_test_data

    clean_path = raw_path.replace("embedbed_test_data_folder_str", embedbed_test_data_folder_str)

    if "S3_TEST_DATA_FOLDER" in clean_path:
        if protocol is None:
            raise RuntimeError("S3_TEST_DATA_FOLDER must include a protocol")
        clean_path = clean_path.replace(
            "S3_TEST_DATA_FOLDER",
            f"{protocol}://{base_path}",
        )

    path_obj = AnyPath(clean_path, **(s3_config_real if use_real_s3_options else {}))

    assert path_obj.protocol_list() == protocols


@pytest.mark.unit
def test_any_path_add():
    """
    Unit test for path composition with "+" operator
    """
    path_obj = AnyPath("folder") / "file"

    result = path_obj + ".txt"

    assert isinstance(result, AnyPath)
    assert result.fs_path.endswith("file.txt")


@pytest.mark.unit
@pytest.mark.real_s3
@pytest.mark.parametrize(
    "path, options, protocols",
    [
        ("foo/bar/file.txt", {}, ["local"]),
        ("s3://bucket/data", {}, ["s3"]),
        ("s3:bucket/data", {}, ["s3"]),
    ],
    ids=["file", "s3", "s3_short"],
)
def test_any_path_is_serializable(path, options, protocols, embedbed_test_data_folder_str):
    """
    Unit test for AnyPath.protocol_list()
    """

    clean_path = path.replace("embedbed_test_data_folder_str", embedbed_test_data_folder_str)

    path_obj = AnyPath(clean_path, **options)

    assert is_serializable(path_obj)


@pytest.mark.unit
def test_check_for_substring(tmp_path):
    pattern = "annotation/calibration/noise*.xml"
    text = "noiseRange"
    d = tmp_path / osp.dirname(pattern)
    d.mkdir(parents=True)
    noise = d / "noise-s1a-wv2-slc-vv-20250331t193928-20250331t193931-058553-073efb-001.xml"
    noise.write_text(SAMPLE_LEGACY_NOISE, encoding="utf-8")
    assert not any_matching_file_contains_pattern(tmp_path, pattern, text)
    noise.write_text(SAMPLE_NOISE, encoding="utf-8")
    assert any_matching_file_contains_pattern(tmp_path, pattern, text)


@pytest.mark.unit
def test_pattern_missing_in_matching_files(tmp_path: Path):
    annotation = tmp_path / "annotation"
    annotation.mkdir()
    (annotation / "metadata.xml").write_text("<root>expected</root>", encoding="utf-8")

    assert not pattern_missing_in_matching_files(str(tmp_path), "annotation/*.xml", "expected")
    assert pattern_missing_in_matching_files(str(tmp_path), "annotation/*.xml", "missing")
    assert pattern_missing_in_matching_files(str(tmp_path), "annotation/*.txt", "expected")


@pytest.mark.unit
def test_compute_json_size():
    payload = {"value": "é", "items": [1, 2]}

    assert compute_json_size(payload) == len(json.dumps(payload).encode("utf-8"))


@pytest.mark.unit
def test_anypath_copy_to_uses_recursive_put_for_local_directory_to_remote(tmp_path: Path):
    source_path = tmp_path / "source.zarr"
    source_path.mkdir()
    (source_path / "zarr.json").write_text("{}", encoding="utf-8")
    target = AnyPath.cast("s3://bucket/output.zarr", anon=True)
    put_calls: list[dict[str, object]] = []

    class FakeRemoteFs:
        def put(self, source: str, target_path: str, *, recursive: bool) -> None:
            put_calls.append(
                {
                    "source": source,
                    "target_path": target_path,
                    "recursive": recursive,
                },
            )

    target._fs = FakeRemoteFs()

    AnyPath.cast(source_path).copy_to(target)

    assert put_calls == [
        {
            "source": str(source_path),
            "target_path": "bucket/output.zarr",
            "recursive": True,
        },
    ]


@pytest.mark.unit
def test_anypath_copy_to_same_remote_protocol_uses_server_side_copy_for_equivalent_fs():
    source = AnyPath.cast("s3://bucket/tmp-output.zarr", anon=True)
    target = AnyPath.cast("s3://bucket/output.zarr", anon=True)
    copy_calls: list[dict[str, object]] = []

    class FakeRemoteFs:
        def isdir(self, path: str) -> bool:
            return path == "bucket/tmp-output.zarr"

        def copy(self, source_path: str, target_path: str, *, recursive: bool) -> None:
            copy_calls.append(
                {
                    "source_path": source_path,
                    "target_path": target_path,
                    "recursive": recursive,
                },
            )

    source._fs = FakeRemoteFs()
    target._fs = FakeRemoteFs()

    source.copy_to(target, max_workers=4)

    assert copy_calls == [
        {
            "source_path": "bucket/tmp-output.zarr",
            "target_path": "bucket/output.zarr",
            "recursive": True,
        },
    ]


@pytest.mark.unit
def test_anypath_copy_to_remote_file_does_not_create_parent_marker():
    source = AnyPath.cast("s3://bucket/source/data.bin", anon=True)
    target = AnyPath.cast("s3://bucket/output/sub/data.bin", anon=True)
    written: dict[str, bytes] = {}

    class FakeRemoteFile(BytesIO):
        def __init__(self, path: str):
            super().__init__()
            self._path = path

        def __enter__(self):
            return self

        def __exit__(self, *args):
            written[self._path] = self.getvalue()
            self.close()

    class FakeRemoteFs:
        def isdir(self, path: str) -> bool:
            return False

        def open(self, path: str, mode: str = "rb", **kwargs: object):
            if mode == "rb":
                assert path == "bucket/source/data.bin"
                return BytesIO(b"data")
            assert mode == "wb"
            assert kwargs == {"block_size": 8}
            return FakeRemoteFile(path)

    fake_fs = FakeRemoteFs()
    source._fs = fake_fs
    target._fs = fake_fs

    source.copy_to(target, block_size=8)

    assert written == {"bucket/output/sub/data.bin": b"data"}
    assert "bucket/output/sub/.keep" not in written


@pytest.mark.unit
@pytest.mark.real_s3
def test_anypath_copy_to_local_to_remote_real_s3(
    tmp_path: Path,
    s3_output_test_data,
    s3_output_config_real,
):
    protocol, base_path = s3_output_test_data
    if protocol is None:
        pytest.skip("S3_OUTPUT_TEST_DATA_FOLDER must include a protocol")

    source_path = tmp_path / "source.zarr"
    source_path.mkdir()
    (source_path / "zarr.json").write_text("{}", encoding="utf-8")
    (source_path / "sub").mkdir()
    (source_path / "sub" / "data.bin").write_bytes(b"data")

    run_path = f"{protocol}://{base_path}/{uuid.uuid4()}"
    target = AnyPath(f"{run_path}/output.zarr", **s3_output_config_real)
    try:
        AnyPath.cast(source_path).copy_to(target, max_workers=2)

        assert (target / "zarr.json").exists()
        assert (target / "sub" / "data.bin").exists()
        with (target / "zarr.json").open("rb") as f:
            assert f.read() == b"{}"
        with (target / "sub" / "data.bin").open("rb") as f:
            assert f.read() == b"data"
    finally:
        run = AnyPath(run_path, **s3_output_config_real)
        if run.exists():
            run.rm(recursive=True)


@pytest.mark.unit
@pytest.mark.real_s3
def test_anypath_copy_to_same_remote_fs_real_s3(
    s3_output_test_data,
    s3_output_config_real,
):
    protocol, base_path = s3_output_test_data
    if protocol is None:
        pytest.skip("S3_OUTPUT_TEST_DATA_FOLDER must include a protocol")

    run_path = f"{protocol}://{base_path}/{uuid.uuid4()}"
    source = AnyPath(f"{run_path}/source.zarr", **s3_output_config_real)
    target = AnyPath(f"{run_path}/output.zarr", **s3_output_config_real)
    try:
        source.mkdir(exist_ok=True)
        with (source / "zarr.json").open("wb") as f:
            f.write(b"{}")
        (source / "sub").mkdir(exist_ok=True)
        with (source / "sub" / "data.bin").open("wb") as f:
            f.write(b"data")

        source.copy_to(target, max_workers=4)

        assert (target / "zarr.json").exists()
        with (target / "zarr.json").open("rb") as f:
            assert f.read() == b"{}"
        with (target / "sub" / "data.bin").open("rb") as f:
            assert f.read() == b"data"
    finally:
        run = AnyPath(run_path, **s3_output_config_real)
        if run.exists():
            run.rm(recursive=True)


@pytest.mark.unit
@pytest.mark.real_s3
def test_anypath_copy_to_remote_to_local_real_s3(
    tmp_path: Path,
    s3_output_test_data,
    s3_output_config_real,
):
    protocol, base_path = s3_output_test_data
    if protocol is None:
        pytest.skip("S3_OUTPUT_TEST_DATA_FOLDER must include a protocol")

    run_path = f"{protocol}://{base_path}/{uuid.uuid4()}"
    source = AnyPath(f"{run_path}/source.zarr", **s3_output_config_real)
    target_path = tmp_path / "downloaded.zarr"
    target = AnyPath.cast(str(target_path))
    try:
        source.mkdir(exist_ok=True)
        with (source / "zarr.json").open("wb") as f:
            f.write(b"{}")
        (source / "sub").mkdir(exist_ok=True)
        with (source / "sub" / "data.bin").open("wb") as f:
            f.write(b"data")

        source.copy_to(target)

        assert (target_path / "zarr.json").read_bytes() == b"{}"
        assert (target_path / "sub" / "data.bin").read_bytes() == b"data"
    finally:
        run = AnyPath(run_path, **s3_output_config_real)
        if run.exists():
            run.rm(recursive=True)


@pytest.mark.unit
def test_anypath_copy_to_local_to_local_directory(tmp_path: Path):
    source_path = tmp_path / "source.zarr"
    source_path.mkdir()
    (source_path / "zarr.json").write_text("{}", encoding="utf-8")
    (source_path / "sub").mkdir()
    (source_path / "sub" / "data.bin").write_bytes(b"data")

    target_path = tmp_path / "out.zarr"
    AnyPath.cast(source_path).copy_to(AnyPath.cast(target_path), max_workers=2)

    assert (target_path / "zarr.json").read_bytes() == b"{}"
    assert (target_path / "sub" / "data.bin").read_bytes() == b"data"


@pytest.mark.unit
def test_replace_text_in_json():
    text = "Old"
    replacement = "NEW"
    json_obj = {"key": f"contain{text}"}
    res = replace_text_in_json(json_obj, text, replacement)
    assert replacement in res["key"]


@pytest.mark.unit
def test_file_md5(embedbed_test_data_folder_str):
    expected_output = "351f7f1e0dd24a485e8642cb1f476ced"
    file_path = AnyPath.cast(embedbed_test_data_folder_str) / "accessor" / "netcdf" / "S3B_SL_1_RBT____20230824T091058_cartesian_an.nc"
    assert file_md5(file_path) == expected_output


@pytest.mark.unit
def test_valid_config_with_client_kwargs():
    cfg = {
        "key": "my-key",
        "secret": "my-secret",
        "client_kwargs": {
            "endpoint_url": "https://s3.example.com",
            "region_name": "eu-west-1",
        },
    }

    result = format_s3_cloud_config(cfg)

    assert result == cfg
    assert result is not cfg  # defensive copy


@pytest.mark.unit
def test_storage_options_to_obstore_config():
    storage_options = {
        "key": "my-key",
        "secret": "my-secret",
        "token": "session-token",
        "anon": True,
        "client_kwargs": {
            "endpoint_url": "https://s3.example.com",
            "region_name": "eu-west-1",
        },
    }

    assert storage_options_to_obstore_config(storage_options) == {
        "access_key_id": "my-key",
        "secret_access_key": "my-secret",
        "session_token": "session-token",
        "endpoint": "https://s3.example.com",
        "region": "eu-west-1",
        "skip_signature": True,
    }


@pytest.mark.unit
def test_valid_flat_config_is_normalized():
    cfg = {
        "key": "my-key",
        "secret": "my-secret",
        "endpoint_url": "https://s3.example.com",
        "region_name": "eu-west-1",
    }

    result = format_s3_cloud_config(cfg)

    assert result["key"] == "my-key"
    assert result["secret"] == "my-secret"
    assert result["client_kwargs"] == {
        "endpoint_url": "https://s3.example.com",
        "region_name": "eu-west-1",
    }


@pytest.mark.unit
@pytest.mark.parametrize(
    "cfg, missing",
    [
        (
            {"secret": "s"},
            ["s3_cloud.key", "s3_cloud.endpoint_url", "s3_cloud.region_name"],
        ),
        (
            {"key": "k"},
            ["s3_cloud.secret", "s3_cloud.endpoint_url", "s3_cloud.region_name"],
        ),
        (
            {"key": "k", "secret": "s"},
            ["s3_cloud.endpoint_url", "s3_cloud.region_name"],
        ),
    ],
)
def test_missing_top_level_parameters(cfg, missing):
    with pytest.raises(MissingConfigurationParameterError) as exc:
        format_s3_cloud_config(cfg)

    msg = str(exc.value)
    for m in missing:
        assert m in msg


@pytest.mark.unit
@pytest.mark.parametrize(
    "cfg, missing",
    [
        (
            {
                "key": "k",
                "secret": "s",
                "client_kwargs": {"endpoint_url": "url"},
            },
            ["s3_cloud.client_kwargs.region_name"],
        ),
        (
            {
                "key": "k",
                "secret": "s",
                "client_kwargs": {"region_name": "r"},
            },
            ["s3_cloud.client_kwargs.endpoint_url"],
        ),
        (
            {
                "key": "k",
                "secret": "s",
                "client_kwargs": {},
            },
            [
                "s3_cloud.client_kwargs.endpoint_url",
                "s3_cloud.client_kwargs.region_name",
            ],
        ),
    ],
)
def test_missing_client_kwargs_parameters(cfg, missing):
    with pytest.raises(MissingConfigurationParameterError) as exc:
        format_s3_cloud_config(cfg)

    msg = str(exc.value)
    for m in missing:
        assert m in msg


@pytest.mark.unit
def test_original_input_is_not_modified():
    cfg = {
        "key": "k",
        "secret": "s",
        "endpoint_url": "url",
        "region_name": "r",
    }

    original = cfg.copy()
    format_s3_cloud_config(cfg)

    assert cfg == original
