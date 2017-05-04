#/usr/bin/env python
# This code was lifted from airflow's setup.py

async = [
    'greenlet>=0.4.9',
    'eventlet>= 0.9.7',
    'gevent>=0.13'
]
celery = [
    'celery>=3.1.17',
    'flower>=0.7.3'
]
cgroups = [
    'cgroupspy>=0.1.4',
]
crypto = ['cryptography>=0.9.3']
datadog = ['datadog>=0.14.0']
doc = [
    'sphinx>=1.2.3',
    'sphinx-argparse>=0.1.13',
    'sphinx-rtd-theme>=0.1.6',
    'Sphinx-PyPI-upload>=0.2.1'
]
docker = ['docker-py>=1.6.0']
druid = ['pydruid>=0.2.1']
emr = ['boto3>=1.0.0']
gcp_api = [
    'httplib2',
    'google-api-python-client>=1.5.0, <1.6.0',
    'oauth2client>=2.0.2, <2.1.0',
    'PyOpenSSL',
]
hdfs = ['snakebite>=2.7.8']
webhdfs = ['hdfs[dataframe,avro,kerberos]>=2.0.4']
jira = ['JIRA>1.0.7']
hive = [
    'hive-thrift-py>=0.0.1',
    'pyhive>=0.1.3',
    'impyla>=0.13.3',
    'unicodecsv>=0.14.1'
]
jdbc = ['jaydebeapi>=0.2.0']
mssql = ['pymssql>=2.1.1', 'unicodecsv>=0.14.1']
mysql = ['mysqlclient>=1.3.6']
rabbitmq = ['librabbitmq>=1.6.1']
oracle = ['cx_Oracle>=5.1.2']
postgres = ['psycopg2>=2.6']
salesforce = ['simple-salesforce>=0.72']
s3 = [
    'boto>=2.36.0',
    'filechunkio>=1.6',
]
samba = ['pysmbclient>=0.1.3']
slack = ['slackclient>=1.0.0']
statsd = ['statsd>=3.0.1, <4.0']
vertica = ['vertica-python>=0.5.1']
ldap = ['ldap3>=0.9.9.1']
kerberos = ['pykerberos>=1.1.13',
            'requests_kerberos>=0.10.0',
            'thrift_sasl>=0.2.0',
            'snakebite[kerberos]>=2.7.8',
            'kerberos>=1.2.5']
password = [
    'bcrypt>=2.0.0',
    'flask-bcrypt>=0.7.1',
]
github_enterprise = ['Flask-OAuthlib>=0.9.1']
qds = ['qds-sdk>=1.9.0']
cloudant = ['cloudant>=0.5.9,<2.0'] # major update coming soon, clamp to 0.x

all_dbs = postgres + mysql + hive + mssql + hdfs + vertica + cloudant
devel = [
    'click',
    'freezegun',
    'jira',
    'lxml>=3.3.4',
    'mock',
    'moto',
    'nose',
    'nose-ignore-docstring==0.2',
    'nose-parameterized',
]
devel_minreq = devel + mysql + doc + password + s3 + cgroups
devel_hadoop = devel_minreq + hive + hdfs + webhdfs + kerberos
devel_all = devel + all_dbs + doc + samba + s3 + slack + crypto + oracle + docker

require={
            'all': devel_all,
            'all_dbs': all_dbs,
            'async': async,
            'celery': celery,
            'cgroups': cgroups,
            'cloudant': cloudant,
            'crypto': crypto,
            'datadog': datadog,
            'devel': devel_minreq,
            'devel_hadoop': devel_hadoop,
            'doc': doc,
            'docker': docker,
            'druid': druid,
            'emr': emr,
            'gcp_api': gcp_api,
            'github_enterprise': github_enterprise,
            'hdfs': hdfs,
            'hive': hive,
            'jdbc': jdbc,
            'kerberos': kerberos,
            'ldap': ldap,
            'mssql': mssql,
            'mysql': mysql,
            'oracle': oracle,
            'password': password,
            'postgres': postgres,
            'qds': qds,
            'rabbitmq': rabbitmq,
            's3': s3,
            'salesforce': salesforce,
            'samba': samba,
            'slack': slack,
            'statsd': statsd,
            'vertica': vertica,
            'webhdfs': webhdfs,
            'jira': jira,
        }

for e in sorted(require.keys(), key=lambda x: (len(require[x]), x)):
    print('{}:'.format(e))
    for r in sorted(require[e]):
        print('    - {}'.format(r))

