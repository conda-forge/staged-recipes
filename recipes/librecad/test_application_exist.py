import shutil

app_name = "librecad"
if shutil.which(app_name):
    print(f"{app_name} is installed.")
else:
    raise FileNotFoundError(f"{app_name} is NOT installed.")