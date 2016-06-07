%PYTHON% setup.py install
if errorlevel 1 exit 1

for %%DIR in (
              etc/salt
              var/cache/salt
              var/run/salt
              srv/salt
              srv/pillar
              var/log/salt
              var/run
       ) do (
              MKDIR %PREFIX%/%%DIR
       )
