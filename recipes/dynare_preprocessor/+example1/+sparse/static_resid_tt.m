function [T_order, T] = static_resid_tt(y, x, params, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 4
    T = [T; NaN(4 - size(T, 1), 1)];
end
T(1) = y(5)^(1+params(6));
T(2) = exp(y(4))*y(3)^params(3);
T(3) = y(5)^(1-params(3));
T(4) = T(2)*T(3);
end
