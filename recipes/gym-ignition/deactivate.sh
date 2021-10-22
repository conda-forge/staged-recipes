export IGN_GAZEBO_SYSTEM_PLUGIN_PATH="$(echo $IGN_GAZEBO_SYSTEM_PLUGIN_PATH | tr ':' '\n' | grep -v "$CONDA_PREFIX/lib/scenario/plugins" | grep -v '^$' | tr '\n' ':')"
