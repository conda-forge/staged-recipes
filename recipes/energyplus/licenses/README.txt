Bundled-component license provenance and source availability
==========================================================

EnergyPlus 26.2.0 source, including the bundled components, is available at:
https://github.com/NatLabRockies/EnergyPlus/archive/refs/tags/v26.2.0.tar.gz
SHA-256: 0f77c71449e2f03fe33c8db2ab1f16aa210322ea978d62bdc38bc47317be408b

The generated *-NOTICES.txt files reproduce copyright/license comment blocks
from this exact source, with their source paths. They supplement rather than
replace EnergyPlus's LICENSE.txt and the bundled LICENSE/COPYING/Legal files.
These notices do not change any component's license.

valijson-LICENSE.txt:
  Valijson 1.0.5, BSD-2-Clause.
  https://github.com/tristanpenman/valijson/blob/8b320f25676030ba13fb90c1bf06133df2628086/LICENSE
  EnergyPlus vendoring commit 02c5e46d888b6917308dc686a8126f48eded23c1
  identifies version 1.0.5. Its schema.hpp matches that upstream release.
  The bundled optional.hpp compatibility header separately uses BSL-1.0;
  its attribution is in valijson-NOTICES.txt and the full Boost license is
  packaged from third_party/kiva/vendor/boost-1.88.0/LICENSE_1_0.txt.

nlohmann-LICENSE.txt:
  JSON for Modern C++ 3.12.0, MIT (whitespace normalized).
  https://github.com/nlohmann/json/blob/55f93686c01528224f448c19128836e7df245f72/LICENSE.MIT
  nlohmann-NOTICES.txt also preserves internal component attributions and the
  license of the bundled doj/alphanum.hpp implementation.

milo-LICENSE.txt:
  The bundled milo headers identify Tencent/Milo Yip and the MIT License.
  Attribution and MIT terms are reproduced from RapidJSON 1.1.0:
  https://github.com/Tencent/rapidjson/blob/f54b0e47a08782a6131cc3d60f94d038fa6e0a51/license.txt
  Only the MIT terms applicable to the bundled milo headers are reproduced;
  RapidJSON's separate JSON_checker and msinttypes components are not
  included by this notice.

SSC/SPLINTER and Eigen:
  SPLINTER's source headers identify MPL-2.0 and are retained in
  ssc-splinter-NOTICES.txt. The full MPL-2.0 text is packaged from
  third_party/eigen/COPYING.MPL2. The exact covered source is available in the
  EnergyPlus source tarball above, under third_party/ssc/splinter/ and the
  respective Eigen directories. Recipe patches to the bundled sources are
  available alongside the recipe:
  https://github.com/conda-forge/staged-recipes/pull/35502

DElight and BCVTB:
  DElight-NOTICES.txt and BCVTB-NOTICES.txt retain their original copyright,
  government-rights notices, disclaimers, and any license terms embedded in
  the bundled source. No substitute license is assigned to these files.

Windows-CalcEngine:
  The original third_party/Windows-CalcEngine/Legal.txt is packaged intact.

SQLite, zlib, and MiniZip:
  SQLite-NOTICES.txt retains the public-domain dedication.
  zlib-NOTICES.txt retains the zlib/MiniZip author and license notices,
  including the embedded Info-ZIP terms.
