#!/bin/bash -ef

cp_envsubst()
{
	src=$1
	dst=$2
	if [ -d $dst ]; then
		dst="$dst/$(basename $src)"
	fi
	cat $src | envsubst '${PREFIX}' > $dst
}

RABBITMQ_HOME=$PREFIX/lib/rabbitmq
mkdir -p $RABBITMQ_HOME

# Fix patching level mismatch and mode
mv b/sbin/rabbitmq-script-wrapper sbin
chmod 755 sbin/rabbitmq-script-wrapper

# Copy files in place.
cp -avf ebin include plugins sbin ${RABBITMQ_HOME}

# man pages
cp -avf share ${PREFIX}

# Render a few files
cp_envsubst sbin/rabbitmq-script-wrapper $RABBITMQ_HOME/sbin
cp_envsubst sbin/rabbitmq-defaults $RABBITMQ_HOME/sbin

# Create links to main apps
for app in ${PREFIX}/bin/rabbitmq{ctl,-server,-plugins}; do
	ln -s ../lib/rabbitmq/sbin/rabbitmq-script-wrapper $app
done

# Make empty dirs
for dir in ${PREFIX}/{etc,var{/lib,/log}}/rabbitmq; do
	mkdir -p $dir
	touch $dir/.mkdir
done
