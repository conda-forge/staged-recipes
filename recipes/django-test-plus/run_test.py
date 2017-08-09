import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['test_plus', 'django.contrib.contenttypes', 'django.contrib.auth']) 
django.setup() 
        
import test_plus
