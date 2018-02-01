import django
from django.conf import settings

settings.configure(INSTALLED_APPS=['rest_pandas'])
django.setup()

import rest_pandas
