export CXXFLAGS=$(echo $CXXFLAGS | sed -E "s/ -std=[^ ]*//")
