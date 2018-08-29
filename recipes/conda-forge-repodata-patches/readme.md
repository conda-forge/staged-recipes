This scheme is ultimately meant to generate one file per subdir, ``patch_instructions.json``.  That file has entries by

```
instructions = {
        "patch_instructions_version": 1,
        "packages": defaultdict(dict),
        "revoke": [],
        "remove": [],
    }
```

```revoke``` and ```remove``` are lists of filenames.  ```remove``` makes the file not show up in the index (it may still be downloadable with a direct URL to the file).  ```revoke``` makes packages uninstallable by adding an unsatisfiable dependency.  This can be made installable by including a channel that has that package (to be created by @jjhelmus).

``packages`` is a dictionary, where keys are package filenames.  Values are dictionaries similar to the contents of each package in repodata.json.  Any values in provided in ``packages`` here overwrite the values in repodata.json.  Any value set to None is removed.

A tool on our end will download this package when it sees updates to it, and will apply the patch_instructions.json to the repodata for the static repodata mirror that @kalefranz has proposed.

cc @conda-forge/core - I tried to add everyone to maintainers.  My apologies if I overlooked anyone.
