function [y, T, residual, g1] = static_2(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(4, 1);
  T(1)=y(5)^(1+params(6));
  residual(1)=(y(2)*params(5)*T(1))-((1-params(3))*y(1));
  T(2)=exp(y(6));
  residual(2)=(y(3))-(params(1)*(y(1)*params(3)*T(2)+y(3)*(1-params(4))));
  T(3)=exp(y(4));
  T(4)=T(3)*y(3)^params(3);
  T(5)=y(5)^(1-params(3));
  residual(3)=(y(1))-(T(4)*T(5));
  residual(4)=(y(3))-(y(3)*(1-params(4))+T(2)*(y(1)-y(2)));
if nargout > 3
    g1_v = NaN(11, 1);
g1_v(1)=params(5)*T(1);
g1_v(2)=T(2);
g1_v(3)=1-params(1)*(1-params(4));
g1_v(4)=(-(T(5)*T(3)*getPowerDeriv(y(3),params(3),1)));
g1_v(5)=1-(1-params(4));
g1_v(6)=y(2)*params(5)*getPowerDeriv(y(5),1+params(6),1);
g1_v(7)=(-(T(4)*getPowerDeriv(y(5),1-params(3),1)));
g1_v(8)=(-(1-params(3)));
g1_v(9)=(-(params(1)*params(3)*T(2)));
g1_v(10)=1;
g1_v(11)=(-T(2));
    if ~isoctave && matlab_ver_less_than('9.8')
        sparse_rowval = double(sparse_rowval);
        sparse_colval = double(sparse_colval);
    end
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 4, 4);
end
end
