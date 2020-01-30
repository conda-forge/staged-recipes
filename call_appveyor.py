import os
import requests
import pprint

print("in the script")

with open(os.path.expanduser("~/.conda-smithy/appveyor.token"), "r") as fh:
    appveyor_token = fh.read().strip()

user = 'conda-forge'
project = 'corrfunc-feedstock-m19hw'

headers = {"Authorization": "Bearer {}".format(appveyor_token)}


def _get_settings():
    url = "https://ci.appveyor.com/api/projects/{}/{}/settings".format(
        user, project
    )
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        raise ValueError(response)
    content = response.json()
    settings = content["settings"]

    if "skipBranchesWithoutAppveyorYml" not in settings:
        print("skip not set!")
    else:
        print("skip setting:", settings["skipBranchesWithoutAppveyorYml"])

    print("settings:\n%s", pprint.pformat(settings))

    return settings


print("initial settings:")
settings = _get_settings()

print("updating settings")

for required_setting in (
        "skipBranchesWithoutAppveyorYml",
        "rollingBuildsOnlyForPullRequests",
        "rollingBuilds",
):
    if not settings[required_setting]:
        print(
            "{: <30}: Current setting for {} = {}."
            "".format(
                project, required_setting, settings[required_setting]
            )
        )
    settings[required_setting] = True

url = "https://ci.appveyor.com/api/projects"
response = requests.put(url, headers=headers, json=settings)
if response.status_code != 204:
    raise ValueError(response)

print("final settings:")
settings = _get_settings()
