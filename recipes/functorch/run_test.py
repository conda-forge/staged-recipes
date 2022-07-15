import torch
from functorch import vmap
x = torch.randn(3)
y = vmap(torch.sin)(x)
assert torch.allclose(y, x.sin())
