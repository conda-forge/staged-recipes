import pkgutil
def get_iris():
    data = pkgutil.get_data(__name__, "datasets/iris_sns.csv")
    return data
def get_bostonhousing():
    data = pkgutil.get_data(__name__, "datasets/BostonHousing.csv")
    return data
def get_heartdisease():
    data = pkgutil.get_data(__name__, "datasets/heartdisease.csv")
    return data
def get_penguins():
    data = pkgutil.get_data(__name__, "datasets/penguins_sns.csv")
    return data
def get_titanic():
    data = pkgutil.get_data(__name__, "datasets/titanic_sns.csv")
    return data
