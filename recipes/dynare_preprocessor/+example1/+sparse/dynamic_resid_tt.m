function [T_order, T] = dynamic_resid_tt(y, x, params, steady_state, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 6
    T = [T; NaN(6 - size(T, 1), 1)];
end
T(1) = y(11)^(1+params(6));
T(2) = y(8)*exp(y(12))/(exp(y(18))*y(14));
T(3) = params(3)*exp(y(18))*y(13)+y(9)*(1-params(4));
T(4) = exp(y(10))*y(3)^params(3);
T(5) = y(11)^(1-params(3));
T(6) = T(4)*T(5);
end
