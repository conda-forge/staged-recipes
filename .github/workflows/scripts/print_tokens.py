import os
import github

for token in [
    "GH_TOKEN",
    "GH_TRAVIS_TOKEN",
    "GH_DRONE_TOKEN",
    "ORGWIDE_GH_TRAVIS_TOKEN"
]:
    try:
        gh = github.Github(os.environ[token])
        login = gh.get_user().login
    except Exception:
        loging = "NOT FOUND"

    print("%s: %s" % (token, login))
