# Recipe Notes

Source code repository for the application is on https://github.com/digital-preservation/csv-validator

As of 2025-01-24, the command line tool (`csv-validator-cmd`) requires at minimum Java 11 to run. The application's pre-compiled JAR file with its JAR dependencies are bundled in the release https://github.com/digital-preservation/csv-validator/releases. The release also includes a Bash script and Bat file to run the application:
* https://github.com/digital-preservation/csv-validator/blob/master/csv-validator-distribution/bin/csv-validator-cmd
* https://github.com/digital-preservation/csv-validator/blob/master/csv-validator-distribution/bin/csv-validator-cmd.bat

The default max memory heap allocation size is 1024m as per the above scripts. If we want to change the default for the Conda recipe then we need to `export csvValidatorMemory=1024` (Linux) or `SET csvValidatorMemory=1024` (Windows) before running the execution script. We can change the max memory as part of the Conda recipe (which requires overriding the source code with a customized execution script) or let users set this setting in their terminal instance before running the command. For now we will use default settings.

Release download includes a GUI application but we will ignore that and remove it from the install. Because of this, the dependency JAR folder may be bigger than necessary, but to simplify things we will just copy over all the dependency JARs included in the release. But for future reference, these JAR files may be removed if GUI is not made available via Conda:
* SwingX
    * swingx-action-1.6.5-1.jar
    * swingx-autocomplete-1.6.5-1.jar
    * swingx-common-1.6.5-1.jar
    * swingx-core-1.6.5-1.jar
    * swingx-graphics-1.6.5-1.jar
    * swingx-painters-1.6.5-1.jar
    * swingx-plaf-1.6.5-1.jar
* Others
    * designgridlayout-1.11.jar
    * scala-swing_2.13-3.0.0.jar

# Debugging Recipe

On Linux, Docker is used to build packages from recipes for testing (`./scripts/run_docker_build.sh`). As per `README.md` in project root: "`staged-recipes` directory is mounted as a volume. The resulting artifacts will be available under `build_artifacts` in the repository directory."

Conda builds will automatically download files from the source defined in `meta.yml` and store them in `/build_artifacts/src_cache`. Files are unpacked to the directory set by `$SRC_DIR` variable (done by Conda).

`/build_artifacts/$PKG_NAME_X/work/build_env_setup.sh` contains all the environment variables set up before running the user-defined `build.sh`. See https://docs.conda.io/projects/conda-build/en/stable/user-guide/environment-variables.html#env-vars for more info.

On Windows, library dependencies are stored in `%BUILD_PREFIX%\Library\lib` or `%LIBRARY_PREFIX%\lib`.

# DevOps Automation

Can set up DevOps flow to update recipe on new release candidate upstream. Have bot change the version and rerun `python build-locally.py` to ensure build works.
