import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['model_utils', 'django.contrib.contenttypes', 'django.contrib.auth']) 
django.setup() 
        
import model_utils
