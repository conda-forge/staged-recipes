export IGN_GAZEBO_SYSTEM_PLUGIN_PATH="$(echo $IGN_GAZEBO_SYSTEM_PLUGIN_PATH | tr ':' '\n' | grep -v '/lib/scenario/plugins' | grep -v '^$' | tr '\n' ':'"
