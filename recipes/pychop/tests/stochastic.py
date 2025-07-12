import torch

# Original versions for reference and comparison
def _chop_stochastic_rounding_original(x, t, emax, subnormal=1, flip=0, explim=1, p=0.5, randfunc=None, *argv, **kwargs):
    if randfunc is None:
        randfunc = lambda n: torch.rand(n, device=x.device)
        
    emin = 1 - emax
    xmin = 2 ** emin
    emins = emin + 1 - t
    xmins = 2 ** emins
    xmax = 2 ** emax * (2 - 2 ** (1 - t))
    
    e = torch.floor(torch.log2(torch.abs(x))).int()
    ktemp = (e < emin) & (e >= emins)
              
    if explim:
        k_sub = ktemp
        k_norm = ~ktemp
    else:
        k_sub = torch.zeros_like(ktemp, dtype=torch.bool)
        k_norm = torch.ones_like(ktemp, dtype=torch.bool)

    w = torch.pow(2.0, t - 1 - e[k_norm].float())
    x[k_norm] = stochastic_rounding(x=x[k_norm] * w, flip=flip, p=p, t=t, randfunc=randfunc)
    x[k_norm] *= 1 / w
    
    if k_sub.any():
        temp = emin - e[k_sub]
        t1 = t - torch.max(temp, torch.zeros_like(temp))
        x[k_sub] = stochastic_rounding(x=x[k_sub] * torch.pow(2, t1 - 1 - e[k_sub].float()), 
                                       flip=flip, p=p, t=t, randfunc=randfunc) * torch.pow(2, e[k_sub].float() - (t1 - 1))
        
    if explim:
        x[(x > xmax) & (x != float('inf'))] = xmax
        x[(x < -xmax) & (x != float('-inf'))] = -xmax
        min_rep = xmin if subnormal == 0 else xmins
        k_small = torch.abs(x) < min_rep
        x[k_small] = 0
                
    return x

def _chop_stochastic_rounding_equal_original(x, t, emax, subnormal=1, flip=0, explim=1, p=0.5, randfunc=None, *argv, **kwargs):
    if randfunc is None:
        randfunc = lambda n: torch.rand(n, device=x.device)
        
    emin = 1 - emax
    xmin = 2 ** emin
    emins = emin + 1 - t
    xmins = 2 ** emins
    
    e = torch.floor(torch.log2(torch.abs(x))).int()
    ktemp = (e < emin) & (e >= emins)
              
    if explim:
        k_sub = ktemp
        k_norm = ~ktemp
    else:
        k_sub = torch.zeros_like(ktemp, dtype=torch.bool)
        k_norm = torch.ones_like(ktemp, dtype=torch.bool)

    w = torch.pow(2.0, t - 1 - e[k_norm].float())
    x[k_norm] = stochastic_rounding_equal(x=x[k_norm] * w, flip=flip, p=p, t=t, randfunc=randfunc)
    x[k_norm] *= 1 / w
    
    if k_sub.any():
        temp = emin - e[k_sub]
        t1 = t - torch.max(temp, torch.zeros_like(temp))
        x[k_sub] = stochastic_rounding_equal(x=x[k_sub] * torch.pow(2, t1 - 1 - e[k_sub].float()), 
                                             flip=flip, p=p, t=t, randfunc=randfunc) * torch.pow(2, e[k_sub].float() - (t1 - 1))
        
    if explim:
        xboundary = 2 ** emax * (2 - 0.5 * 2 ** (1 - t))
        x[x >= xboundary] = float('inf')
        x[x <= -xboundary] = float('-inf')
        min_rep = xmin if subnormal == 0 else xmins
        k_small = torch.abs(x) < min_rep
        x[k_small] = 0

    return x

# Optimized versions with consistent output
def _chop_stochastic_rounding(x, t, emax, subnormal=1, flip=0, explim=1, p=0.5, randfunc=None, *argv, **kwargs):
    if randfunc is None:
        randfunc = lambda n: torch.rand(n, device=x.device)

    # Precompute constants
    emin = 1 - emax
    xmin = 2 ** emin
    emins = emin + 1 - t
    xmins = 2 ** emins
    xmax = 2 ** emax * (2 - 2 ** (1 - t))

    # Efficient exponent calculation
    abs_x = torch.abs(x)
    e = torch.log2(abs_x).floor().int()
    ktemp = (e < emin) & (e >= emins)

    # Minimize tensor creation
    if explim:
        k_sub = ktemp
        k_norm = ~ktemp
    else:
        k_sub = torch.empty_like(ktemp, dtype=torch.bool, device=x.device).fill_(False)
        k_norm = torch.empty_like(ktemp, dtype=torch.bool, device=x.device).fill_(True)

    # Normal range: avoid in-place to match original
    w = torch.pow(2.0, t - 1 - e[k_norm].float())
    x_norm = x[k_norm] * w
    x_norm = stochastic_rounding(x_norm, flip=flip, p=p, t=t, randfunc=randfunc) * (1 / w)
    x[k_norm] = x_norm

    # Subnormal range: avoid in-place to match original
    if k_sub.any():
        temp = emin - e[k_sub]
        t1 = t - torch.clamp(temp, min=0)  # Optimized with clamp
        w_sub = torch.pow(2.0, t1 - 1 - e[k_sub].float())
        x_sub = x[k_sub] * w_sub
        x_sub = stochastic_rounding(x_sub, flip=flip, p=p, t=t, randfunc=randfunc) * torch.pow(2.0, e[k_sub].float() - (t1 - 1))
        x[k_sub] = x_sub

    # Boundary handling with vectorized operations
    if explim:
        x.masked_fill_((x > xmax) & (x != float('inf')), xmax)
        x.masked_fill_((x < -xmax) & (x != float('-inf')), -xmax)
        min_rep = xmin if subnormal == 0 else xmins
        x.masked_fill_(abs_x < min_rep, 0)

    return x

def _chop_stochastic_rounding_equal(x, t, emax, subnormal=1, flip=0, explim=1, p=0.5, randfunc=None, *argv, **kwargs):
    if randfunc is None:
        randfunc = lambda n: torch.rand(n, device=x.device)

    # Precompute constants
    emin = 1 - emax
    xmin = 2 ** emin
    emins = emin + 1 - t
    xmins = 2 ** emins
    xboundary = 2 ** emax * (2 - 0.5 * 2 ** (1 - t))

    # Efficient exponent calculation
    abs_x = torch.abs(x)
    e = torch.log2(abs_x).floor().int()
    ktemp = (e < emin) & (e >= emins)

    # Minimize tensor creation
    if explim:
        k_sub = ktemp
        k_norm = ~ktemp
    else:
        k_sub = torch.empty_like(ktemp, dtype=torch.bool, device=x.device).fill_(False)
        k_norm = torch.empty_like(ktemp, dtype=torch.bool, device=x.device).fill_(True)

    # Normal range: avoid in-place to match original
    w = torch.pow(2.0, t - 1 - e[k_norm].float())
    x_norm = x[k_norm] * w
    x_norm = stochastic_rounding_equal(x_norm, flip=flip, p=p, t=t, randfunc=randfunc) * (1 / w)
    x[k_norm] = x_norm

    # Subnormal range: avoid in-place to match original
    if k_sub.any():
        temp = emin - e[k_sub]
        t1 = t - torch.clamp(temp, min=0)  # Optimized with clamp
        w_sub = torch.pow(2.0, t1 - 1 - e[k_sub].float())
        x_sub = x[k_sub] * w_sub
        x_sub = stochastic_rounding_equal(x_sub, flip=flip, p=p, t=t, randfunc=randfunc) * torch.pow(2.0, e[k_sub].float() - (t1 - 1))
        x[k_sub] = x_sub

    # Boundary handling with vectorized operations
    if explim:
        x.masked_fill_(x >= xboundary, float('inf'))
        x.masked_fill_(x <= -xboundary, float('-inf'))
        min_rep = xmin if subnormal == 0 else xmins
        x.masked_fill_(abs_x < min_rep, 0)

    return x

# Supporting functions 
def stochastic_rounding(x, flip=0, p=0.5, t=24, randfunc=None):
    if randfunc is None:
        randfunc = lambda n: torch.rand(n, device=x.device)
    
    y = torch.abs(x)
    frac = y - torch.floor(y)
    
    if not frac.any():
        y = x
    else:
        sign = lambda x: torch.sign(x) + (x == 0).float()
        rnd = randfunc(x.shape)
        j = rnd <= frac
        y[j] = torch.ceil(y[j])
        y[~j] = torch.floor(y[~j])
        y = sign(x) * y
        
        if flip:
            temp = torch.randint(0, 2, y.shape, device=x.device)
            k = temp <= p
            if k.any():
                u = torch.abs(y[k])
                b = torch.randint(1, t - 1, u.shape, device=x.device)
                u = torch.bitwise_xor(u.to(torch.int32), torch.pow(2, b - 1).to(torch.int32)).float()
                y[k] = sign(y[k]) * u
    
    return y

def stochastic_rounding_equal(x, flip=0, p=0.5, t=24, randfunc=None):
    if randfunc is None:
        randfunc = lambda n: torch.rand(n, device=x.device)
    
    y = torch.abs(x)
    frac = y - torch.floor(y)
    
    if not frac.any():
        y = x
    else:
        sign = lambda x: torch.sign(x) + (x == 0).float()
        rnd = randfunc(x.shape)
        j = rnd <= 0.5
        y[j] = torch.ceil(y[j])
        y[~j] = torch.floor(y[~j])
        y = sign(x) * y
    
    if flip:
        temp = torch.randint(0, 2, y.shape, device=x.device)
        k = temp <= p
        if k.any():
            u = torch.abs(y[k])
            b = torch.randint(1, t - 1, u.shape, device=x.device)
            u = torch.bitwise_xor(u.to(torch.int32), torch.pow(2, b - 1).to(torch.int32)).float()
            y[k] = sign(y[k]) * u
    
    return y

# Verification and comparison
if __name__ == "__main__":
    # Test inputs
    x = torch.tensor([1.7, -2.3, 3.5, 0.1, -0.05, 1000.0], device='cpu')
    t, emax = 11, 15

    # Set random seed for reproducibility
    torch.manual_seed(42)

    # Original outputs
    x_orig1 = x.clone()
    out_orig1 = _chop_stochastic_rounding_original(x_orig1, t=t, emax=emax)
    x_orig2 = x.clone()
    out_orig2 = _chop_stochastic_rounding_equal_original(x_orig2, t=t, emax=emax)

    # Optimized outputs
    torch.manual_seed(42)  # Reset seed to match random numbers
    x_opt1 = x.clone()
    out_opt1 = _chop_stochastic_rounding(x_opt1, t=t, emax=emax)
    x_opt2 = x.clone()
    out_opt2 = _chop_stochastic_rounding_equal(x_opt2, t=t, emax=emax)

    # Compare outputs
    print("Original stochastic_rounding:", out_orig1)
    print("Optimized stochastic_rounding:", out_opt1)
    print("Match (stochastic_rounding):", torch.allclose(out_orig1, out_opt1, atol=1e-6))
    
    print("\nOriginal stochastic_rounding_equal:", out_orig2)
    print("Optimized stochastic_rounding_equal:", out_opt2)
    print("Match (stochastic_rounding_equal):", torch.allclose(out_orig2, out_opt2, atol=1e-6))

    # Test on CUDA if available
    if torch.cuda.is_available():
        x_cuda = x.to('cuda')
        
        torch.manual_seed(42)
        x_orig1_cuda = x_cuda.clone()
        out_orig1_cuda = _chop_stochastic_rounding_original(x_orig1_cuda, t=t, emax=emax)
        x_orig2_cuda = x_cuda.clone()
        out_orig2_cuda = _chop_stochastic_rounding_equal_original(x_orig2_cuda, t=t, emax=emax)

        torch.manual_seed(42)
        x_opt1_cuda = x_cuda.clone()
        out_opt1_cuda = _chop_stochastic_rounding(x_opt1_cuda, t=t, emax=emax)
        x_opt2_cuda = x_cuda.clone()
        out_opt2_cuda = _chop_stochastic_rounding_equal(x_opt2_cuda, t=t, emax=emax)

        print("\nCUDA Original stochastic_rounding:", out_orig1_cuda)
        print("CUDA Optimized stochastic_rounding:", out_opt1_cuda)
        print("CUDA Match (stochastic_rounding):", torch.allclose(out_orig1_cuda, out_opt1_cuda, atol=1e-6))
        
        print("\nCUDA Original stochastic_rounding_equal:", out_orig2_cuda)
        print("CUDA Optimized stochastic_rounding_equal:", out_opt2_cuda)
        print("CUDA Match (stochastic_rounding_equal):", torch.allclose(out_orig2_cuda, out_opt2_cuda, atol=1e-6))