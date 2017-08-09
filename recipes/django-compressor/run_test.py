import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['compressor', 'django.contrib.contenttypes', 'django.contrib.auth']) 
django.setup() 
        
import compressor
