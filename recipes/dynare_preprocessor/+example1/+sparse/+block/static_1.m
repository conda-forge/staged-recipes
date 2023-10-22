function [y, T, residual, g1] = static_1(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(2, 1);
  residual(1)=(y(4))-(y(4)*params(2)+y(6)*params(7)+x(1));
  residual(2)=(y(6))-(y(4)*params(7)+y(6)*params(2)+x(2));
if nargout > 3
    g1_v = NaN(4, 1);
g1_v(1)=(-params(7));
g1_v(2)=1-params(2);
g1_v(3)=1-params(2);
g1_v(4)=(-params(7));
    if ~isoctave && matlab_ver_less_than('9.8')
        sparse_rowval = double(sparse_rowval);
        sparse_colval = double(sparse_colval);
    end
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 2, 2);
end
end
