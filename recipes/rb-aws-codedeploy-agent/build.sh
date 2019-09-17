#!/usr/bin/env bash
set -euf

grep -lRE '/(etc|opt)/codedeploy-agent' . \
  | xargs -I {} sed -i \
                    -e "s|/opt/codedeploy-agent|${PREFIX}|" \
                    -e "s|/etc/codedeploy-agent|${PREFIX}/etc|" {} \

sed -i \
    -e "s|/var/log/aws/codedeploy-agent|${PREFIX}/log/codedeploy-agent|" \
    -e "s|/state/.pid|/run|" \
    conf/codedeployagent.yml

mkdir -p ${PREFIX}/etc
cp conf/codedeployagent.yml ${PREFIX}/etc
mkdir -p ${PREFIX}/log/codedeploy-agent
touch ${PREFIX}/log/codedeploy-agent/.mkdir

sed -i \
    -e "s/aws_codedeploy_agent/${PKG_NAME}/" \
    -e "s/bin,conf/bin,certs/" \
    -e "s/\(spec.version\s*=\s*\)0.1/\1'${PKG_VERSION}'/" \
    -e "/spec.bindir/a\ spec.executables = ['codedeploy-agent', 'codedeploy-local']" \
    -e "s/json_pure/json/" \
    codedeploy_agent-1.1.0.gemspec

gem build codedeploy_agent-1.1.0.gemspec
gem install -N -l -V --norc --ignore-dependencies ${PKG_NAME}-${PKG_VERSION}.gem

