import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['compressor', 'django.contrib.contenttypes', 'django.contrib.auth'], 
                  STATIC_ROOT = 'static', STATIC_URL = '/static/', MEDIA_ROOT = 'media', MEDIA_URL = '/media/') 
django.setup() 
        
import compressor
