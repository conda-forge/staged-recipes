import ffcx.codegeneration.jit
import ufl


def test_compiles():
    cell = ufl.triangle
    element = ufl.FiniteElement("Lagrange", cell, 1)
    u, v = ufl.TrialFunction(element), ufl.TestFunction(element)
    a = ufl.inner(ufl.grad(u), ufl.grad(v)) * ufl.dx
    forms = [a]

    compiled_forms, module, code = ffcx.codegeneration.jit.compile_forms(forms)
