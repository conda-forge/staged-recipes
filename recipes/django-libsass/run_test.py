import django
from django.conf import settings
settings.configure(
	INSTALLED_APPS=['compressor'],
	STATIC_URL='/',
	STATIC_ROOT='',
    COMPRESS_PRECOMPILERS = (('text/x-scss', 'django_libsass.SassCompiler'),)
) 
django.setup() 
import django_libsass
