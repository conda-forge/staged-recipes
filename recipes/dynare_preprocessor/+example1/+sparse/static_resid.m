function [residual, T_order, T] = static_resid(y, x, params, T_order, T)
if nargin < 5
    T_order = -1;
    T = NaN(4, 1);
end
[T_order, T] = example1.sparse.static_resid_tt(y, x, params, T_order, T);
residual = NaN(6, 1);
    residual(1) = (y(2)*params(5)*T(1)) - ((1-params(3))*y(1));
    residual(2) = (y(3)) - (params(1)*(y(1)*params(3)*exp(y(6))+y(3)*(1-params(4))));
    residual(3) = (y(1)) - (T(4));
    residual(4) = (y(3)) - (y(3)*(1-params(4))+exp(y(6))*(y(1)-y(2)));
    residual(5) = (y(4)) - (y(4)*params(2)+y(6)*params(7)+x(1));
    residual(6) = (y(6)) - (y(4)*params(7)+y(6)*params(2)+x(2));
end
