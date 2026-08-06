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
from pathlib import Path

import pytest

from eopf.product import versioning
from eopf.product.versioning import VersionEntry, get_version_info, load_versioning_table


@pytest.fixture
def fake_versioning_dir(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Path:
    versioning_dir = tmp_path / "versioning"
    versioning_dir.mkdir()

    (versioning_dir / "s01.yaml").write_text(
        """
versioning_table:
  S01SEWRAW:
    - processing_version: "1.0.0"
      eopf_cpm_version: "3.0.2"
      common_pfsd_version: "3.0.0"
      specific_pfsd_version: "1.4.3"
      mapping_version: "1.0.1"

    - processing_version: "1.1.0"
      eopf_cpm_version: "3.1.0"
      common_pfsd_version: "3.1.0"
      specific_pfsd_version: "1.5.0"
      mapping_version: "1.1.0"
""",
        encoding="utf-8",
    )
    (versioning_dir / "s02.yaml").write_text(
        """
versioning_table:
  S02MSIL1C:
    - processing_version: "1.0.0"
      eopf_cpm_version: "3.0.0"
      common_pfsd_version: "3.0.0"
      specific_pfsd_version: "1.1.0"
      mapping_version: "1.0.0"

  S02MSIL2A:
    - processing_version: "1.0.0"
      eopf_cpm_version: "3.0.0"
      common_pfsd_version: "3.0.0"
      specific_pfsd_version: "1.1.0"
      mapping_version: "1.0.0"
""",
        encoding="utf-8",
    )
    (versioning_dir / "s03.yaml").write_text(
        """
versioning_table:
  S03SYNVGT:
    - processing_version: "1.0.0"
      eopf_cpm_version: "3.0.0"
      common_pfsd_version: "3.0.0"
      specific_pfsd_version: "1.0.0"
""",
        encoding="utf-8",
    )

    monkeypatch.setattr(versioning, "_VERSIONING_RESOURCE", versioning_dir)
    versioning.load_versioning_table.cache_clear()

    return versioning_dir


@pytest.mark.unit
def test_load_versioning_table(fake_versioning_dir: Path) -> None:
    table = load_versioning_table()

    assert set(table.keys()) == {"S01SEWRAW", "S02MSIL1C", "S02MSIL2A", "S03SYNVGT"}
    assert len(table["S01SEWRAW"]) == 2

    first = table["S01SEWRAW"][0]
    assert isinstance(first, VersionEntry)
    assert first.product_type == "S01SEWRAW"
    assert first.processing_version == "1.0.0"
    assert first.mapping_version == "1.0.1"
    assert first.eopf_cpm_version == "3.0.2"


@pytest.mark.unit
def test_get_version_info_returns_entry(fake_versioning_dir: Path) -> None:
    entry = get_version_info("S01SEWRAW", "1.0.0")

    assert entry is not None
    assert entry.product_type == "S01SEWRAW"
    assert entry.processing_version == "1.0.0"
    assert entry.mapping_version == "1.0.1"
    assert entry.common_pfsd_version == "3.0.0"
    assert entry.specific_pfsd_version == "1.4.3"


@pytest.mark.unit
def test_get_version_info_returns_entry_with_mapping_version_for_newer_processing_version(
        fake_versioning_dir: Path,
) -> None:
    entry = get_version_info("S01SEWRAW", "1.1.0")

    assert entry is not None
    assert entry.product_type == "S01SEWRAW"
    assert entry.processing_version == "1.1.0"
    assert entry.mapping_version == "1.1.0"
    assert entry.eopf_cpm_version == "3.1.0"


@pytest.mark.unit
def test_get_version_info_returns_entry_without_mapping_version_for_non_mapped_product(
        fake_versioning_dir: Path,
) -> None:
    entry = get_version_info("S03SYNVGT", "1.0.0")

    assert entry is not None
    assert entry.product_type == "S03SYNVGT"
    assert entry.processing_version == "1.0.0"
    assert entry.mapping_version is None


@pytest.mark.unit
def test_get_version_info_returns_none_for_unknown_product_type(
        fake_versioning_dir: Path,
) -> None:
    entry = get_version_info("UNKNOWN", "1.0.0")

    assert entry is None


@pytest.mark.unit
def test_get_version_info_returns_none_for_unknown_processing_version(
        fake_versioning_dir: Path,
) -> None:
    entry = get_version_info("S01SEWRAW", "9.9.9")

    assert entry is None


@pytest.mark.unit
def test_load_versioning_table_raises_on_duplicate_processing_version(
        tmp_path: Path,
        monkeypatch: pytest.MonkeyPatch,
) -> None:
    versioning_dir = tmp_path / "versioning"
    versioning_dir.mkdir()

    (versioning_dir / "s01.yaml").write_text(
        """
versioning_table:
  S01SEWRAW:
    - processing_version: "1.0.0"
      eopf_cpm_version: "3.0.0"
      common_pfsd_version: "3.0.0"
      specific_pfsd_version: "1.4.3"
      mapping_version: "1.0.0"

    - processing_version: "1.0.0"
      eopf_cpm_version: "3.0.2"
      common_pfsd_version: "3.0.0"
      specific_pfsd_version: "1.4.3"
      mapping_version: "1.0.1"
""",
        encoding="utf-8",
    )

    monkeypatch.setattr(versioning, "_VERSIONING_RESOURCE", versioning_dir)
    versioning.load_versioning_table.cache_clear()

    with pytest.raises(ValueError, match="Duplicate versioning entry"):
        versioning.load_versioning_table()
