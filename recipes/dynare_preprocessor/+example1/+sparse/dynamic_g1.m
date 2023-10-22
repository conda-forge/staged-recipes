function [g1, T_order, T] = dynamic_g1(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T_order, T)
if nargin < 9
    T_order = -1;
    T = NaN(14, 1);
end
[T_order, T] = example1.sparse.dynamic_g1_tt(y, x, params, steady_state, T_order, T);
g1_v = NaN(26, 1);
g1_v(1)=T(11);
g1_v(2)=(-(1-params(4)));
g1_v(3)=(-params(2));
g1_v(4)=(-params(7));
g1_v(5)=(-params(7));
g1_v(6)=(-params(2));
g1_v(7)=(-(1-params(3)));
g1_v(8)=1;
g1_v(9)=(-exp(y(12)));
g1_v(10)=params(5)*T(1);
g1_v(11)=(-(params(1)*T(3)*T(7)));
g1_v(12)=exp(y(12));
g1_v(13)=1-params(1)*T(2)*(1-params(4));
g1_v(14)=1;
g1_v(15)=(-T(6));
g1_v(16)=1;
g1_v(17)=y(8)*params(5)*T(12);
g1_v(18)=(-(T(4)*T(13)));
g1_v(19)=(-(params(1)*T(2)*T(3)));
g1_v(20)=(-(exp(y(12))*(y(7)-y(8))));
g1_v(21)=1;
g1_v(22)=(-(params(1)*T(2)*params(3)*exp(y(18))));
g1_v(23)=(-(params(1)*T(3)*T(9)));
g1_v(24)=(-(params(1)*(T(3)*T(14)+T(2)*params(3)*exp(y(18))*y(13))));
g1_v(25)=(-1);
g1_v(26)=(-1);
if ~isoctave && matlab_ver_less_than('9.8')
    sparse_rowval = double(sparse_rowval);
    sparse_colval = double(sparse_colval);
end
g1 = sparse(sparse_rowval, sparse_colval, g1_v, 6, 20);
end
