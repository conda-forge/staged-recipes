"""Make sure that all "essential" services are present."""
from pkg_resources import require


package_names = [
    "types_aiobotocore_cloudformation",
    "types_aiobotocore_dynamodb",
    "types_aiobotocore_ec2",
    "types_aiobotocore_lambda",
    "types_aiobotocore_rds",
    "types_aiobotocore_s3",
    "types_aiobotocore_sqs",
]

for name in package_names:
    res = require(name)
    print("Package '" + name + "' provided by " + str(res) + ".")
