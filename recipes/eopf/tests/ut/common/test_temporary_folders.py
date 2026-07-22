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
import gc
import os.path
import time

import pytest

from eopf import EOConfiguration
from eopf.common.file_utils import AnyPath
from eopf.common.temp_utils import EOTemporaryFolder


@pytest.mark.unit
def test_local_temp_dir(OUTPUT_DIR):
    EOConfiguration()["temporary__folder"] = OUTPUT_DIR
    temp_dir = EOTemporaryFolder().get().copy()
    assert temp_dir.exists()
    new_file = temp_dir / "testfile.txt"
    new_file.touch()
    assert new_file.exists() and new_file.isfile()
    new_dir = temp_dir / "testfolder"
    new_dir.mkdir()
    assert len(temp_dir.ls()) != 0
    EOTemporaryFolder.clear()
    assert not temp_dir.exists()


@pytest.mark.unit
def test_local_temp_dir_no_clean(OUTPUT_DIR):
    EOConfiguration()["temporary__folder"] = OUTPUT_DIR
    temp_dir: AnyPath = EOTemporaryFolder(dont_clean=True).get().copy()
    assert temp_dir.exists()
    new_file = temp_dir / "testfile.txt"
    new_file.touch()
    assert new_file.exists() and new_file.isfile()
    new_dir = temp_dir / "testfolder"
    new_dir.mkdir()
    assert len(temp_dir.ls()) != 0
    EOTemporaryFolder.clear()
    assert temp_dir.exists()
    temp_dir.rm(recursive=True)
    assert not temp_dir.exists()


@pytest.mark.unit
def test_local_temp_dir_error_cases(OUTPUT_DIR):
    try:
        EOConfiguration()["temporary__folder"] = os.path.join(OUTPUT_DIR, "NoTHere")
        EOConfiguration()["temporary__folder_create_folder"] = False
        with pytest.raises(ValueError):
            EOTemporaryFolder()
        EOConfiguration()["temporary__folder"] = "s3://truc/test_s3_temp_dir"
        with pytest.raises(Exception):
            # this should be NoCredetialsError from botocore
            # however we want to avoid adding botocore as a direct depency
            EOTemporaryFolder()
    finally:
        EOConfiguration()["temporary__folder_create_folder"] = True


@pytest.mark.unit
@pytest.mark.real_s3
def test_s3_temp_dir(OUTPUT_DIR, TEST_DATA_SECRET, s3_output_test_data):

    EOConfiguration()["temporary__folder"] = f"{s3_output_test_data[0]}://{s3_output_test_data[1]}/test_s3_temp_dir"
    EOConfiguration()["temporary__folder_create_folder"] = True

    EOConfiguration()["temporary__folder_s3_secret"] = "test_data"
    # test_data_secret = {"test_data": S3_OUTPUT_CONFIG_REAL}
    # with (AnyPath.cast(OUTPUT_DIR) / "test_data_secret.json").open("w") as f:
    #    json.dump(test_data_secret, f)
    # CredentialStore(os.path.join(OUTPUT_DIR, "test_data_secret.json"))
    temp_dir = EOTemporaryFolder().get().copy()
    assert temp_dir.exists()
    new_file = temp_dir / "testfile.txt"
    new_file.touch()
    assert new_file.exists() and new_file.isfile()
    new_dir = temp_dir / "testfolder"
    new_dir.mkdir()
    assert len(temp_dir.ls()) != 0
    EOTemporaryFolder.clear()
    time.sleep(10)
    gc.collect()

    assert not temp_dir.exists()


@pytest.mark.unit
@pytest.mark.real_s3
def test_s3_temp_dir_cleanup_bis(OUTPUT_DIR, TEST_DATA_SECRET, s3_output_test_data):
    EOConfiguration()["temporary__folder"] = f"{s3_output_test_data[0]}://{s3_output_test_data[1]}/test_s3_temp_dir"
    EOConfiguration()["temporary__folder_create_folder"] = True

    EOConfiguration()["temporary__folder_s3_secret"] = "test_data"
    # test_data_secret = {"test_data": S3_OUTPUT_CONFIG_REAL}
    # with (AnyPath.cast(OUTPUT_DIR) / "test_data_secret.json").open("w") as f:
    #    json.dump(test_data_secret, f)
    # CredentialStore(os.path.join(OUTPUT_DIR, "test_data_secret.json"))
    temp_dir = EOTemporaryFolder().get()
    assert temp_dir.exists()
    new_file = temp_dir / "testfile.txt"
    new_file.touch()
    assert new_file.exists() and new_file.isfile()
    new_dir = temp_dir / "testfolder"
    new_dir.mkdir()
    assert len(temp_dir.ls()) != 0

    EOTemporaryFolder().cleanup()

    assert not temp_dir.exists()
    EOTemporaryFolder.clear()
