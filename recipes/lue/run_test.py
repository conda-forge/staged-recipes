import lue
import lue.data_model as ldm

print('lue version: {}'.format(lue.lue_version))
print('git hash:    {}'.format(lue.git_short_sha1))

res = None
res = ldm.SpaceDomain
assert res is not None
