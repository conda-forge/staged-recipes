import libtbx.load_env

env = libtbx.env

# store order
env.installed_order = [module.name for module in env.module_list]

for module_name in ['cbflib', 'cbflib_adaptbx', 'dxtbx']:
  if module_name in env.module_dict:
    module = env.module_dict[module_name]
    if module in env.module_list:
      env.module_list.remove(module)
    env.module_dict.pop(module_name)
  if module_name in env.explicitly_requested_modules:
    env.explicitly_requested_modules.remove(module_name)
  if module_name in env.module_dist_paths:
    env.module_dist_paths.pop(module_name)

env.pickle()
