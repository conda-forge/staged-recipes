set -euf 

pushd nginx

  source $PREFIX/lib/nginx/configure.env

  ./configure $NGINX_CONFIGURE \
    --with-cc-opt="$NGINX_CC_OPT" \
    --with-ld-opt="$NGINX_LD_OPT" \
    --add-dynamic-module=../njs/nginx

  # This makes the modules
  make modules

  cp objs/ngx_{http,stream}_js_module.so $PREFIX/lib/nginx/modules

  cp $RECIPE_DIR/module-njs.conf $PREFIX/etc/nginx/main.d
popd
