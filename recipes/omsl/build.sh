mkdir $PREFIX/lib/omlibrary
case $MSLVERSION in
'3.2.3')
  echo 'Installing MSL 3.2.3 ...'
  cp -R $SRC_DIR/Complex.mo $PREFIX/"lib/omlibrary/Complex 4.0.0.mo"
  cp -R $SRC_DIR/Modelica $PREFIX/"lib/omlibrary/Modelica 3.2.3"
  cp -R $SRC_DIR/ModelicaServices $PREFIX/"lib/omlibrary/ModelicaServices 4.0.0"
;;
'4.0.0')
  echo 'Installing MSL 4.0.0 ...'
  cp -R $SRC_DIR/Complex.mo $PREFIX/"lib/omlibrary/Complex 4.0.0.mo"
  cp -R $SRC_DIR/Modelica $PREFIX/"lib/omlibrary/Modelica 4.0.0"
  cp -R $SRC_DIR/ModelicaServices $PREFIX/"lib/omlibrary/ModelicaServices 4.0.0"
;;
*)
  echo don\'t know
  exit 1
;;
esac
