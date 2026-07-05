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
import os
from pathlib import Path
from typing import Any, Optional

import pytest

from eopf.config.secret_providers.dict_secret_store import DictSecretStore
from eopf.config.secret_providers.file_secret_store import FileSecretStore
from eopf.config.secrets_manager import SecretsManager


@pytest.fixture
def secret_conf_file(FOLDER_WITH_CONFIGS):
    return os.path.join(FOLDER_WITH_CONFIGS, "secrets.json")


@pytest.fixture
def secret_conf_file2(FOLDER_WITH_CONFIGS):
    return os.path.join(FOLDER_WITH_CONFIGS, "secrets2.json")


@pytest.fixture
def clean_credential_store():
    SecretsManager.clear()
    yield
    SecretsManager.clear()


class SecretProvider:
    def __init__(self, secrets: dict[str, dict[str, Any]]) -> None:
        self._secrets = secrets

    def secrets(self, secret_name: Optional[str] = None) -> Optional[dict[str, Any]]:
        if secret_name is None:
            return self._secrets
        return self._secrets.get(secret_name)

    def resolve_secret_name(self, path: str) -> Optional[str]:
        for secret_path, secret_name in self._secrets.get("secret_bindings", {}).items():
            if path.startswith(secret_path):
                return secret_name
        return None


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_load_secrets(clean_credential_store, secret_conf_file, secret_conf_file2):
    os.environ["SECRET_PASS"] = "<SECRET>"
    os.environ["SECRET_PASS2"] = "<SECRET2>"
    secret_conf_path = Path(secret_conf_file)
    secret_conf_path2 = Path(secret_conf_file2)
    secret_store = SecretsManager()
    provider = FileSecretStore(
        path=secret_conf_path,
    )
    provider2 = FileSecretStore(
        path=secret_conf_path2,
    )
    secret_store.add_provider(provider)
    secret_store.add_provider(provider2)
    assert secret_store.secrets("common") == {
        "key": "key",
        "secret": "<SECRET>",
        "client_kwargs": {
            "endpoint_url": "<URL>",
            "region_name": "<REGION>",
        },
        "s3_additional_kwargs": {"StorageClass": "EXPRESS_ONEZONE"},
    }
    assert secret_store.secrets("cpm-input") == {
        "key": "key2",
        "secret": "<SECRET2>",
        "client_kwargs": {
            "endpoint_url": "<URL>",
            "region_name": "<REGION>",
        },
        "s3_additional_kwargs": {"StorageClass": "EXPRESS_ONEZONE"},
    }
    assert secret_store.resolve_secret_name("s3://common/somestuff") == "common"
    assert secret_store.resolve_secret_name("s3://somestuff") is None


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
@pytest.mark.parametrize(
    ("filename", "contents", "secret_name"),
    [
        (
            "secrets.json",
            """
{
    "secret_bindings": {
        "s3://json-secret": "json-secret"
    },
    "json-secret": {
        "key": "json-key",
        "secret": "${FORMAT_SECRET}"
    }
}
""",
            "json-secret",
        ),
        (
            "secrets.yaml",
            """
secret_bindings:
  s3://yaml-secret: yaml-secret
yaml-secret:
  key: yaml-key
  secret: ${FORMAT_SECRET}
""",
            "yaml-secret",
        ),
        (
            "secrets.yml",
            """
secret_bindings:
  s3://yml-secret: yml-secret
yml-secret:
  key: yml-key
  secret: ${FORMAT_SECRET}
""",
            "yml-secret",
        ),
        (
            "secrets.toml",
            """
[secret_bindings]
"s3://toml-secret" = "toml-secret"

[toml-secret]
key = "toml-key"
secret = "${FORMAT_SECRET}"
""",
            "toml-secret",
        ),
    ],
)
def test_load_secret_file_formats(clean_credential_store, tmp_path, monkeypatch, filename, contents, secret_name):
    monkeypatch.setenv("FORMAT_SECRET", "<FORMAT_SECRET>")
    secret_path = tmp_path / filename
    secret_path.write_text(contents, encoding="utf-8")

    provider = FileSecretStore(path=secret_path)

    assert provider.secrets(secret_name) == {
        "key": f"{secret_name.split('-')[0]}-key",
        "secret": "<FORMAT_SECRET>",
    }
    assert provider.resolve_secret_name(f"s3://{secret_name}/data") == secret_name


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_dict_secret_store_returns_secret_by_name():
    provider = DictSecretStore(
        {
            "common": {
                "key": "dict-key",
                "secret": "dict-secret",
            },
        },
    )

    assert provider.secrets("common") == {
        "key": "dict-key",
        "secret": "dict-secret",
    }


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_dict_secret_store_returns_all_secrets():
    secrets = {
        "common": {
            "key": "dict-key",
            "secret": "dict-secret",
        },
        "cpm-input": {
            "key": "input-key",
            "secret": "input-secret",
        },
    }

    provider = DictSecretStore(secrets)

    assert provider.secrets() == secrets


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_dict_secret_store_returns_none_for_unknown_secret():
    provider = DictSecretStore(
        {
            "common": {
                "key": "dict-key",
                "secret": "dict-secret",
            },
        },
    )

    assert provider.secrets("missing") is None


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_dict_secret_store_resolves_secret_name_from_binding():
    provider = DictSecretStore(
        {
            "secret_bindings": {
                "s3://dict-bucket": "dict-secret",
            },
            "dict-secret": {
                "key": "dict-key",
                "secret": "dict-secret-value",
            },
        },
    )

    assert provider.resolve_secret_name("s3://dict-bucket/object") == "dict-secret"
    assert provider.resolve_secret_name("s3://other-bucket/object") is None


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_secret_store_uses_dict_secret_store_provider(clean_credential_store):
    secret_store = SecretsManager()
    secret_store.add_provider(
        DictSecretStore(
            {
                "secret_bindings": {
                    "s3://dict-bucket": "dict-secret",
                },
                "dict-secret": {
                    "key": "dict-key",
                    "secret": "dict-secret-value",
                },
            },
        ),
    )

    assert secret_store.resolve_secret_name("s3://dict-bucket/object") == "dict-secret"
    assert secret_store.secrets("dict-secret") == {
        "key": "dict-key",
        "secret": "dict-secret-value",
    }


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_secret_store_single_provider_does_not_warn_as_duplicate(clean_credential_store, caplog):
    secret_store = SecretsManager()
    secret_store.add_provider(
        DictSecretStore(
            {
                "secret_bindings": {
                    "s3://bucket": "test_data",
                },
                "test_data": {
                    "key": "key",
                    "secret": "secret",
                },
            },
        ),
    )

    assert secret_store.resolve_secret_name("s3://bucket/object") == "test_data"
    assert secret_store.secrets("test_data") == {
        "key": "key",
        "secret": "secret",
    }
    assert "Duplicate secret provider" not in caplog.text


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_secret_store_returns_first_provider_secret_when_multiple_providers_match(clean_credential_store, caplog):
    secret_store = SecretsManager()
    secret_store.add_provider(
        DictSecretStore(
            {
                "common": {
                    "key": "first-key",
                    "secret": "first-secret",
                },
            },
        ),
    )
    secret_store.add_provider(
        DictSecretStore(
            {
                "common": {
                    "key": "second-key",
                    "secret": "second-secret",
                },
            },
        ),
    )

    assert secret_store.secrets("common") == {
        "key": "first-key",
        "secret": "first-secret",
    }
    assert "Duplicate secret provider : common" in caplog.text


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_secret_store_returns_first_provider_binding_when_multiple_providers_match(clean_credential_store, caplog):
    secret_store = SecretsManager()
    secret_store.add_provider(DictSecretStore({"secret_bindings": {"s3://bucket": "first-secret"}}))
    secret_store.add_provider(DictSecretStore({"secret_bindings": {"s3://bucket": "second-secret"}}))

    assert secret_store.resolve_secret_name("s3://bucket/object") == "first-secret"
    assert "Duplicate secret provider : first-secret" in caplog.text
