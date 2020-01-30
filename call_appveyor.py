import os
import requests
import pprint

print("in the script")

with open(os.path.expanduser("~/.conda-smithy/appveyor.token"), "r") as fh:
    appveyor_token = fh.read().strip()

user = 'conda-forge'
project = 'corrfunc-feedstock-ypgn6'

headers = {"Authorization": "Bearer {}".format(appveyor_token)}

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
