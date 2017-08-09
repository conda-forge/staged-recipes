import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['crispy_forms', 'django.contrib.contenttypes', 'django.contrib.auth']) 
django.setup() 
        
import crispy_forms
