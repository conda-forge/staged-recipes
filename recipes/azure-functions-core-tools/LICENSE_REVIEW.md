# Third-party license collection for Core Tools 4.16.1

This file is a review note and is not listed in `about.license_file`.

The recipe retains the language workers so that Python Functions can run locally.
`collect_licenses.py` combines the existing `nuget-licenses` downloads with
supplemental notices in one content-deduplicated directory. The original
`THIRD_PARTY_NUGET_LICENSES.md` report is retained. It collects:

- Core Tools and templates licenses, and all existing NuGet license downloads.
- The LICENSE and THIRD-PARTY-NOTICES of the .NET runtime packs selected by the
  published `func.runtimeconfig.json` and target runtime identifier. Other
  versions/platforms and SDK/reference packs in the cache are not scanned.
- `LICENCE.txt` in AccentedCommandLineParser 2.0.1 (the two-clause FreeBSD license).
  That package has the text at `lib/netstandard2.0/LICENCE.txt` despite missing
  license metadata.
- Notices from the published workers and inside Java JARs, including the Java
  worker and Application Insights agent. Original paths are recorded in an index.
  Documents with the same filename cannot overwrite each other.
- Versioned official LICENSE/ThirdPartyNotices documents for the Python and Java
  workers, all four PowerShell workers, and their PowerShell SDK versions
  7.0.13, 7.2.23, 7.4.19 and 7.6.5. SDK versions come from the worker
  source projects at the matching release tags.
- Notices stripped from the bundled Python dependencies: Azure Functions SDK,
  extensions-base, grpcio, protobuf, dateutil, six, MarkupSafe, Werkzeug,
  typing_extensions and uvloop (including its vendored libuv notices and authors).

`license-sources.json` records each externally collected document's official
source URL, release version, archive member where applicable, and SHA-256.
The build verifies these checksums and the worker NuGet versions before copying
the documents. Updating a worker requires reviewing the corresponding snapshots.
The collection step performs no network requests.

The 47 upstream source records share 23 byte-distinct snapshot files in the
recipe. Original URLs, versions, archive members and checksums are retained for
every record. The final collection deduplicates by SHA-256 across *all* inputs,
regardless of filename or extension. It does not merge merely similar licenses
or discard differing copyright/notice text. The recipe packages only this
combined text directory, rather than also copying the raw NuGet downloads and
runtime notices a second time. Notices embedded in published workers/JARs are
left intact. The collection provides their separately accessible license copy.
uvloop/libuv supplemental notices are included only when the published Python
worker contains uvloop. libuv's documentation-only CC BY 4.0 license is excluded:
the worker bundles the library, not the libuv documentation.

The supplemental collector does not recursively scan the NuGet cache. This
avoids collecting build-only packages and worker assets for unselected platforms
through that path. The existing NuGet metadata report/download scope is
unchanged. This is not a complete published-file-to-package attribution audit.

Python dependencies were identified by reading files from the official
Microsoft.Azure.Functions.PythonWorker 4.46.0 nupkg, without executing worker code.
The sampled Linux x64 trees cover Python 3.9, 3.12, 3.13 and 3.14. Version constants
identify grpcio 1.70.0/1.75.1, protobuf 5.29.6/6.33.6, dateutil 2.9.0.post0,
six 1.17.0, uvloop 0.21.0/0.22.1, and the Azure package versions in the manifest.
Source comparison against official wheels identifies MarkupSafe 3.0.3 and
typing_extensions 4.15.0/4.16.0. A comparison of every Werkzeug `.py` file identifies
3.1.8 in all four sampled trees. The Azure Functions runtime wheels omit their
LICENSE. The Python worker repository's matching source release supplies it.

## Unresolved license information

The official packages below contain neither license/licenseUrl metadata nor a
license document. Their copyright notices do not supply redistribution terms.

| Package | Version | Official feed in Core Tools' NuGet.Config |
| --- | --- | --- |
| Microsoft.Azure.AppService.Middleware | 1.5.11 | AzureFunctions |
| Microsoft.Azure.AppService.Middleware.Functions | 1.5.11 | AzureFunctions |
| Microsoft.Azure.AppService.Middleware.Modules | 1.5.11 | AzureFunctions |
| Microsoft.Azure.AppService.Middleware.NetCore | 1.5.11 | AzureFunctions |
| Microsoft.Azure.WebSites.DataProtection | 2.1.91-alpha | AzureFunctionsTempStaging |

The Middleware nuspecs reference source commit
`b38e32cae470f8e2535512178a72b7a714f3738c` without a repository URL.
DataProtection supplies neither a source repository nor license metadata.
Authoritative terms for these packages still need to be obtained from upstream
and reviewed by the conda-forge reviewers.

The review also identified dependencies whose license URLs point to Microsoft
EULAs (`aspnetcomponent_rtw_enu.htm` and `NET_Library_EULA_ENU.txt`). The existing
NuGet report and downloaded documents are retained. Those terms and the final
combined `about.license` expression still need review. The existing `MIT` value
identifies Core Tools' own license and does not establish the terms of these
dependencies. This document collection does not resolve those questions.

References:

- [Core Tools dependency versions](https://github.com/Azure/azure-functions-core-tools/blob/4.16.1/eng/build/Packages.props)
- [Official NuGet feeds and mappings](https://github.com/Azure/azure-functions-core-tools/blob/4.16.1/NuGet.Config)
- [Review identifying the gaps](https://github.com/conda-forge/staged-recipes/pull/34802#issuecomment-6877530245)
