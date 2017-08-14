import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['pytest_django', 'django.contrib.contenttypes', 'django.contrib.auth']) 
django.setup() 
        
import pytest_django
