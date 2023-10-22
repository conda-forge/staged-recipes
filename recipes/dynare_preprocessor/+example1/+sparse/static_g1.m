function [g1, T_order, T] = static_g1(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T_order, T)
if nargin < 8
    T_order = -1;
    T = NaN(4, 1);
end
[T_order, T] = example1.sparse.static_g1_tt(y, x, params, T_order, T);
g1_v = NaN(18, 1);
g1_v(1)=(-(1-params(3)));
g1_v(2)=(-(params(1)*params(3)*exp(y(6))));
g1_v(3)=1;
g1_v(4)=(-exp(y(6)));
g1_v(5)=params(5)*T(1);
g1_v(6)=exp(y(6));
g1_v(7)=1-params(1)*(1-params(4));
g1_v(8)=(-(T(3)*exp(y(4))*getPowerDeriv(y(3),params(3),1)));
g1_v(9)=1-(1-params(4));
g1_v(10)=(-T(4));
g1_v(11)=1-params(2);
g1_v(12)=(-params(7));
g1_v(13)=y(2)*params(5)*getPowerDeriv(y(5),1+params(6),1);
g1_v(14)=(-(T(2)*getPowerDeriv(y(5),1-params(3),1)));
g1_v(15)=(-(params(1)*y(1)*params(3)*exp(y(6))));
g1_v(16)=(-(exp(y(6))*(y(1)-y(2))));
g1_v(17)=(-params(7));
g1_v(18)=1-params(2);
if ~isoctave && matlab_ver_less_than('9.8')
    sparse_rowval = double(sparse_rowval);
    sparse_colval = double(sparse_colval);
end
g1 = sparse(sparse_rowval, sparse_colval, g1_v, 6, 6);
end
