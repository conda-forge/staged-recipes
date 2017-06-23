import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['django_redis', 'django.contrib.contenttypes', 'django.contrib.auth']) 
django.setup() 
        
import django_redis
import django_redis.client
import django_redis.serializers
import django_redis.compressors
import redis
