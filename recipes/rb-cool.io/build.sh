# BUILD
gem unpack {{ name }}-{{ version }}.gem
rm .../ext/libev
make -C {{ PREFIX }}/lib/ruby/gems/{{ ruby }}.0/gems/{{ name }}-{{ version }}/ext/{{ name }} clean
gem spec {{ name }}-{{ version }}.gem > {{ name }}-{{ version }}.gemspec
gem build {{ name }}-{{ version }}.gemspec
gem install -N -l -V --norc --ignore-dependencies {{ name }}-{{ version }}.gem
