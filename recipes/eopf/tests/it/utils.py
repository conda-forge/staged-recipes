import logging
import os
import sys
from typing import Optional, Union

from eopf.common.file_utils import AnyPath

# Mappings corresponding to unavailable products on s3 bucket
EXCEPTED_MAPPINGS = [
    "S01SN1RAW.json",
    "S01SN4RAW.json",
    "S01SENRAW.json",
    "S01SN2RAW.json",
    "S01SN6RAW.json",
    "S01SS2RAW.json",
    "S01SS5RAW.json",
    "S01SS6RAW.json",
    "S01SN5RAW.json",
]

# not supported
EXCEPTED_SUFFIXES = [".tar", ".gz", ".zip", ".json"]

DEFAULT_S3_CONFIG = {
    "key": os.environ.get("S3_KEY"),
    "secret": os.environ.get("S3_SECRET"),
    "client_kwargs": {"endpoint_url": os.environ.get("S3_URL"), "region_name": os.environ.get("S3_REGION")},
}

DEFAULT_S3_TEST_PRODUCTS_PATHS = [
    AnyPath.cast("s3://dpr-cpm-input/cpm/integration_ci_test_data/s01/", **DEFAULT_S3_CONFIG),
    AnyPath.cast("s3://dpr-cpm-input/cpm/integration_ci_test_data/s02/", **DEFAULT_S3_CONFIG),
    AnyPath.cast("s3://dpr-cpm-input/cpm/integration_ci_test_data/s03/", **DEFAULT_S3_CONFIG),
]


def get_test_products_list(
    test_data_folder: Optional[Union[AnyPath, list[AnyPath]]] = None,
) -> list[AnyPath]:
    missing = [v for v in ["S3_KEY", "S3_SECRET", "S3_URL", "S3_REGION"] if not os.environ.get(v)]
    if missing:
        raise RuntimeError(f"Missing S3 env vars: {', '.join(missing)}")

    if test_data_folder is None:
        test_data_folder = DEFAULT_S3_TEST_PRODUCTS_PATHS
    if isinstance(test_data_folder, AnyPath):
        test_products: list[AnyPath] = test_data_folder.ls()
    else:
        test_products: list[AnyPath] = list()
        for product_list in test_data_folder:
            test_products.extend(product_list.ls())

    # exclude products with the suffixes in EXCEPTED_SUFFIXES
    test_products = [
        test_product
        for test_product in test_products
        if set(test_product.suffixes).isdisjoint(set(EXCEPTED_SUFFIXES)) and not test_product.is_archive_candidate()
    ]
    return test_products


# Create a test logger
def get_test_logger() -> logging.Logger:

    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    formatter = logging.Formatter("%(asctime)s | %(levelname)s | %(message)s")

    stdout_handler = logging.StreamHandler(sys.stdout)
    stdout_handler.setLevel(logging.DEBUG)
    stdout_handler.setFormatter(formatter)

    file_handler = logging.FileHandler("load_eop.log", mode="w")
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(formatter)

    logger.addHandler(file_handler)
    logger.addHandler(stdout_handler)

    return logger
