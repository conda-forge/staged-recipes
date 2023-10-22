function [T_order, T] = dynamic_g1_tt(y, x, params, steady_state, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = example1.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
T_order = 1;
if size(T, 1) < 14
    T = [T; NaN(14 - size(T, 1), 1)];
end
T(7) = exp(y(12))/(exp(y(18))*y(14));
T(8) = exp(y(18))*y(14)*exp(y(18))*y(14);
T(9) = (-(y(8)*exp(y(12))*exp(y(18))))/T(8);
T(10) = exp(y(10))*getPowerDeriv(y(3),params(3),1);
T(11) = (-(T(5)*T(10)));
T(12) = getPowerDeriv(y(11),1+params(6),1);
T(13) = getPowerDeriv(y(11),1-params(3),1);
T(14) = (-(y(8)*exp(y(12))*exp(y(18))*y(14)))/T(8);
end
