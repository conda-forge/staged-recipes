"""This helper script generates the text for each output in the recipe since
many patterns are repeated."""

import itertools

def generate_text_for_one_module(
    name: str,
    version: list[str],
    libraries: list[list[str]],
    deps: list[str] = [],
    build: list[str] = [],
    include: str | None = None,
    lib_match: str | None = None,
) -> str:
    include = name if include is None else include
    lib_match = name if lib_match is None else lib_match
    name_with_somajor = f"libnvpl-{name}{version[0].split('.')[0]}"
    deps_expanded = "\n".join(
        f"""        - {{{{ pin_subpackage("{dep}") }}}}""" for dep in deps
    )
    build_expanded = "\n".join(f"""        - {lib}""" for lib in build)
    lib_tests_expanded = "".join(
        f"""        - test -f $PREFIX/lib/libnvpl_{lib}.so\n"""
        for lib in itertools.chain(*libraries)
    )
    lib0_tests_expanded = ""
    for libs, v in zip(libraries, version):
        lib0_tests_expanded += "".join(
            f"""
        - test -f $PREFIX/lib/libnvpl_{lib}.so.{v.split('.')[0]}
        - test -f $PREFIX/lib/libnvpl_{lib}.so.{v}"""
            for lib in libs
        )

    return f"""
  - name: libnvpl-{name}-dev
    build:
      run_exports:
        - {{{{ pin_subpackage("{name_with_somajor}") }}}}
    files:
      - include/nvpl_{name}*
      - include/nvpl_{name}*/**
      - lib/cmake/nvpl_{name}*/**
      - lib/libnvpl_{lib_match}*.so
    requirements:
      host:
        - {{{{ pin_subpackage("{name_with_somajor}", exact=True) }}}}
        - {{{{ pin_subpackage("libnvpl-common-dev", exact=True) }}}}
      run:
        - {{{{ pin_subpackage("{name_with_somajor}", exact=True) }}}}
        - {{{{ pin_subpackage("libnvpl-common-dev", exact=True) }}}}
      run_constrained:
        - arm-variant * {{{{ arm_variant_type }}}}
    test:
      commands:
        - test -f $PREFIX/include/nvpl_{include}.h
        - test -f $PREFIX/lib/cmake/nvpl_{name}/nvpl_{name}-config.cmake
{lib_tests_expanded}
  - name: {name_with_somajor}
    build:
      run_exports:
        - {{{{ pin_subpackage("{name_with_somajor}") }}}}
    files:
      - lib/libnvpl_{lib_match}*.so.*
    requirements:
      build:
        - {{{{ compiler('c') }}}}
        - {{{{ stdlib('c') }}}}
        - arm-variant * {{{{ arm_variant_type }}}}
{build_expanded}
      host:
{deps_expanded}
      run:
{deps_expanded}
      run_constrained:
        - arm-variant * {{{{ arm_variant_type }}}}
    test:
      commands:{lib0_tests_expanded}
"""


if __name__ == "__main__":
    nvpl_packages = [
        {
            "name": "blas",
            "version": [
                "0.3.0",
                "0.2.0",
            ],
            "libraries": [
                [
                    "blas_core",
                    "blas_ilp64_gomp",
                    "blas_ilp64_seq",
                    "blas_lp64_gomp",
                    "blas_lp64_seq",
                ],
                [
                    "blacs_ilp64_mpich",
                    "blacs_ilp64_openmpi3",
                    "blacs_ilp64_openmpi4",
                    "blacs_ilp64_openmpi5",
                    "blacs_lp64_mpich",
                    "blacs_lp64_openmpi3",
                    "blacs_lp64_openmpi4",
                    "blacs_lp64_openmpi5",
                ],
            ],
            "lib_match": "bla",
        },
        {
            "name": "fft",
            "version": ["0.3.0"],
            "libraries": [
                [
                    "fftw",
                ]
            ],
            "include": "fftw",
        },
        {
            "name": "lapack",
            "version": ["0.2.3"],
            "libraries": [
                [
                    "lapack_core",
                    "lapack_ilp64_gomp",
                    "lapack_ilp64_seq",
                    "lapack_lp64_gomp",
                    "lapack_lp64_seq",
                ]
            ],
            "deps": [
                "libnvpl-blas0",
            ],
        },
        {
            "name": "rand",
            "version": ["0.5.0"],
            "libraries": [
                [
                    "rand",
                    "rand_mt",
                ]
            ],
        },
        {
            "name": "scalapack",
            "version": ["0.2.0"],
            "libraries": [
                [
                    "scalapack_ilp64",
                    "scalapack_lp64",
                ]
            ],
        },
        {
            "name": "sparse",
            "version": ["0.3.0"],
            "libraries": [
                [
                    "sparse",
                ]
            ],
        },
        {
            "name": "tensor",
            "version": ["0.2.0"],
            "libraries": [
                [
                    "tensor",
                ]
            ],
            "deps": [
                "libnvpl-blas0",
            ],
            "build": [
                "libgomp",
            ],
        },
    ]

    with open("outputs.yaml", "w") as f:
        for package in nvpl_packages:
            f.write(
                generate_text_for_one_module(
                    **package,
                )
            )


"""
- name: libnvpl-dev
# For convenience only! Not to be used in host requirements!
requirements:
    run:
    - {{ pin_subpackage("libnvpl-blas-dev", exact=True) }}
    - {{ pin_subpackage("libnvpl-common-dev", exact=True) }}
    - {{ pin_subpackage("libnvpl-fft-dev", exact=True) }}
    - {{ pin_subpackage("libnvpl-lapack-dev", exact=True) }}
    - {{ pin_subpackage("libnvpl-rand-dev", exact=True) }}
    - {{ pin_subpackage("libnvpl-scalapack-dev", exact=True) }}
    - {{ pin_subpackage("libnvpl-sparse-dev", exact=True) }}
    - {{ pin_subpackage("libnvpl-tensor-dev", exact=True) }}

- name: libnvpl-common-dev
files:
    - lib/cmake/nvpl/
    - lib/cmake/nvpl_common/
test:
    commands:
    - test -f $PREFIX/lib/cmake/nvpl/nvpl-config.cmake
    - test -f $PREFIX/lib/cmake/nvpl_common/nvpl_common-config.cmake

"""
