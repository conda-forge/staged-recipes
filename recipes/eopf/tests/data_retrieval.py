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
import concurrent.futures
import os
import sys
import time
from typing import TYPE_CHECKING

import fsspec

if TYPE_CHECKING:  # pragma: no cover
    pass

PARENT_DATA_PATH = os.path.abspath(os.path.join(os.path.abspath(os.path.dirname(__file__)), ".."))
TEST_DATA_PATH = os.path.join(PARENT_DATA_PATH, os.path.abspath(os.environ.get("TEST_DATA_FOLDER", "ut/data")))
EMBEDED_TEST_DATA_PATH = os.path.join(PARENT_DATA_PATH, "tests", "ut/data")
MAPPING_PATH = os.path.join(PARENT_DATA_PATH, "eopf", "ut/store", "mapping")
TRIGGER_TEMPLATE_PATH = os.path.join(PARENT_DATA_PATH, "eopf", "ut/triggering", "template")
TEST_ONLY_ONE_PRODUCT = os.environ.get("TEST_ONLY_ONE_PRODUCT") in [True, "True", "true", 1, "1"]

S3_TEST_DATA_PROTOCOL, S3_TEST_DATA_PATH = fsspec.core.split_protocol(os.environ.get("S3_TEST_DATA_FOLDER", ""))
S3_OUTPUT_TEST_DATA_PROTOCOL, S3_OUTPUT_TEST_DATA_PATH = fsspec.core.split_protocol(
    os.environ.get("S3_OUTPUT_TEST_DATA_FOLDER", ""),
)
S3_CONFIG_FAKE = dict(
    check=False,
    create=False,
    key="aaaa",
    secret="bbbbb",
    client_kwargs=dict(endpoint_url="https://localhost", region_name="local"),
)
S3_CONFIG_REAL = dict(
    key=os.environ.get("S3_KEY"),
    secret=os.environ.get("S3_SECRET"),
    client_kwargs=dict(endpoint_url=os.environ.get("S3_URL"), region_name=os.environ.get("S3_REGION")),
)
S3_OUTPUT_CONFIG_REAL = dict(
    key=os.environ.get("S3_OUTPUT_KEY"),
    secret=os.environ.get("S3_OUTPUT_SECRET"),
    client_kwargs=dict(endpoint_url=os.environ.get("S3_OUTPUT_URL"), region_name=os.environ.get("S3_OUTPUT_REGION")),
)


def load_file_from_s3(filename, data_mapper, dest_path):
    real_path = os.path.join(data_mapper.root, filename)
    real_dest_path = os.path.join(dest_path, filename)
    dir_file_name = os.path.dirname(real_path)
    if not os.path.isfile(real_dest_path):
        os.makedirs(dir_file_name, exist_ok=True)
        data_mapper.fs.get(real_path, real_dest_path)


def load_data(mission: str = ""):
    if S3_TEST_DATA_PROTOCOL == "s3":
        print(f"Data folder configuration found for S3 storage: {S3_TEST_DATA_PROTOCOL}://{S3_TEST_DATA_PATH}")
        start = time.time()
        data_mapper = fsspec.get_mapper(f"{S3_TEST_DATA_PROTOCOL}://{S3_TEST_DATA_PATH}", **S3_CONFIG_REAL)
        os.makedirs(TEST_DATA_PATH, exist_ok=True)
        with concurrent.futures.ThreadPoolExecutor() as executor:
            pool = [
                executor.submit(load_file_from_s3, file, data_mapper, TEST_DATA_PATH)
                for file in data_mapper
                if file.startswith(mission)
            ]
            concurrent.futures.wait(pool)

        end = time.time()
        print(f"Finished S3 data retrieval {end - start}")
    else:
        print("No Data folder configuration for S3 storage.")


if __name__ == "__main__":
    # used at import time to prevent @glob_fixture to be loaded before the data is loaded
    if len(sys.argv) > 1:
        mission = sys.argv[1]
    else:
        mission = ""
    load_data(mission)
