#!/bin/bash
FONT_DIR=$PREFIX/fonts
SHARED_FONT_CONFIG_DIR=$PREFIX/share/fontconfig/conf.avail
FONT_CONFIG_DIR=$PREFIX/etc/fonts/config.d


mkdir -p $FONT_DIR || true
mkdir -p $SHARED_FONT_CONFIG_DIR || true
mkdir -p $FONT_CONFIG_DIR || true

install -v -m644 ./ttf/*.ttf ${PREFIX}/fonts

# Make sure font configuration files are installed
for CONFIG in ./fontconfig/*.conf;
do
  install -v -m644 $CONFIG $SHARED_FONT_CONFIG_DIR
  ln -sr $SHARED_FONT_CONFIG_DIR/$(basename $CONFIG) $FONT_CONFIG_DIR/$(basename $CONFIG)
done

