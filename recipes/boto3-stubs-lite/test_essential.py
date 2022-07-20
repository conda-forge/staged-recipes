"""Make sure that all "essential" services are present."""

from mypy_boto3_builder.service_name import ServiceName
from pkg_resources import require

essential_service_names = ServiceName.ESSENTIAL

for name in essential_service_names:
    res = require("mypy_boto3_" + name)
    print("Service '" + name + "' provided by " + str(res) + ".")
