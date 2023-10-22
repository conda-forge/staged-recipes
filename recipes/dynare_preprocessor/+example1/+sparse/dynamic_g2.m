function [g2_v, T_order, T] = dynamic_g2(y, x, params, steady_state, T_order, T)
if nargin < 6
    T_order = -1;
    T = NaN(14, 1);
end
[T_order, T] = example1.sparse.dynamic_g2_tt(y, x, params, steady_state, T_order, T);
g2_v = NaN(28, 1);
g2_v(1)=params(5)*T(12);
g2_v(2)=y(8)*params(5)*getPowerDeriv(y(11),1+params(6),2);
g2_v(3)=(-(params(1)*params(3)*exp(y(18))*T(7)));
g2_v(4)=(-(params(1)*params(3)*exp(y(18))*T(9)));
g2_v(5)=(-(params(1)*T(2)*params(3)*exp(y(18))));
g2_v(6)=(-(params(1)*(T(2)*params(3)*exp(y(18))+params(3)*exp(y(18))*T(14))));
g2_v(7)=(-(params(1)*T(3)*(-(exp(y(12))*exp(y(18))))/T(8)));
g2_v(8)=(-(params(1)*(1-params(4))*T(7)));
g2_v(9)=(-(params(1)*T(3)*T(7)));
g2_v(10)=(-(params(1)*(params(3)*exp(y(18))*y(13)*T(7)+T(3)*(-(exp(y(12))*exp(y(18))*y(14)))/T(8))));
g2_v(11)=(-(params(1)*T(3)*(-((-(y(8)*exp(y(12))*exp(y(18))))*(exp(y(18))*exp(y(18))*y(14)+exp(y(18))*exp(y(18))*y(14))))/(T(8)*T(8))));
g2_v(12)=(-(params(1)*(1-params(4))*T(9)));
g2_v(13)=(-(params(1)*T(3)*T(9)));
g2_v(14)=(-(params(1)*(params(3)*exp(y(18))*y(13)*T(9)+T(3)*((-(y(8)*exp(y(12))*exp(y(18))))*T(8)-(-(y(8)*exp(y(12))*exp(y(18))))*(T(8)+T(8)))/(T(8)*T(8)))));
g2_v(15)=(-(params(1)*T(2)*(1-params(4))));
g2_v(16)=(-(params(1)*(1-params(4))*T(14)));
g2_v(17)=(-(params(1)*T(2)*T(3)));
g2_v(18)=(-(params(1)*(T(3)*T(14)+T(2)*params(3)*exp(y(18))*y(13))));
g2_v(19)=(-(params(1)*(params(3)*exp(y(18))*y(13)*T(14)+T(3)*(T(8)*(-(y(8)*exp(y(12))*exp(y(18))*y(14)))-(-(y(8)*exp(y(12))*exp(y(18))*y(14)))*(T(8)+T(8)))/(T(8)*T(8))+T(2)*params(3)*exp(y(18))*y(13)+params(3)*exp(y(18))*y(13)*T(14))));
g2_v(20)=(-(T(5)*exp(y(10))*getPowerDeriv(y(3),params(3),2)));
g2_v(21)=T(11);
g2_v(22)=(-(T(10)*T(13)));
g2_v(23)=(-T(6));
g2_v(24)=(-(T(4)*T(13)));
g2_v(25)=(-(T(4)*getPowerDeriv(y(11),1-params(3),2)));
g2_v(26)=(-exp(y(12)));
g2_v(27)=exp(y(12));
g2_v(28)=(-(exp(y(12))*(y(7)-y(8))));
end
