import jax
import jax.numpy as jnp
import numpy as np
import torch
import torchax
import torchax.interop
import torchax.train


model = torch.nn.Linear(2, 1)
with torch.no_grad():
    model.weight.copy_(torch.tensor([[2.0, -1.0]]))
    model.bias.fill_(0.5)

params, apply = torchax.extract_jax(model)
x = jnp.array([[1.0, 3.0], [2.0, 1.0]], dtype=jnp.float32)
predictions = jax.jit(apply)(params, (x,))
np.testing.assert_allclose(predictions, [[-0.5], [3.5]], rtol=1e-6)


def total(params):
    return jnp.sum(apply(params, (x,)))


value, grads = jax.jit(jax.value_and_grad(total))(params)
np.testing.assert_allclose(value, 3.0, rtol=1e-6)
np.testing.assert_allclose(grads["weight"], [[3.0, 4.0]], rtol=1e-6)
np.testing.assert_allclose(grads["bias"], [2.0], rtol=1e-6)
print("TorchAX translation, JIT and autodiff passed")
