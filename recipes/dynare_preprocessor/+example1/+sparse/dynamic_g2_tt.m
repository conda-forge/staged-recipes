function T = dynamic_g2_tt(y, x, params, steady_state)
if T_order >= 2
    return
end
[T_order, T] = example1.sparse.dynamic_g1_tt(y, x, params, steady_state, T_order, T);
T_order = 2;
if size(T, 1) < 14
    T = [T; NaN(14 - size(T, 1), 1)];
end
end
