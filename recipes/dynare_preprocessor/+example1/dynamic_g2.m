function g2 = dynamic_g2(T, y, x, params, steady_state, it_, T_flag)
% function g2 = dynamic_g2(T, y, x, params, steady_state, it_, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T             [#temp variables by 1]     double   vector of temporary terms to be filled by function
%   y             [#dynamic variables by 1]  double   vector of endogenous variables in the order stored
%                                                     in M_.lead_lag_incidence; see the Manual
%   x             [nperiods by M_.exo_nbr]   double   matrix of exogenous variables (in declaration order)
%                                                     for all simulation periods
%   steady_state  [M_.endo_nbr by 1]         double   vector of steady state values
%   params        [M_.param_nbr by 1]        double   vector of parameter values in declaration order
%   it_           scalar                     double   time period for exogenous variables for which
%                                                     to evaluate the model
%   T_flag        boolean                    boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   g2
%

if T_flag
    T = example1.dynamic_g2_tt(T, y, x, params, steady_state, it_);
end
g2_i = zeros(48,1);
g2_j = zeros(48,1);
g2_v = zeros(48,1);

g2_i(1)=1;
g2_i(2)=1;
g2_i(3)=1;
g2_i(4)=2;
g2_i(5)=2;
g2_i(6)=2;
g2_i(7)=2;
g2_i(8)=2;
g2_i(9)=2;
g2_i(10)=2;
g2_i(11)=2;
g2_i(12)=2;
g2_i(13)=2;
g2_i(14)=2;
g2_i(15)=2;
g2_i(16)=2;
g2_i(17)=2;
g2_i(18)=2;
g2_i(19)=2;
g2_i(20)=2;
g2_i(21)=2;
g2_i(22)=2;
g2_i(23)=2;
g2_i(24)=2;
g2_i(25)=2;
g2_i(26)=2;
g2_i(27)=2;
g2_i(28)=2;
g2_i(29)=2;
g2_i(30)=2;
g2_i(31)=2;
g2_i(32)=2;
g2_i(33)=2;
g2_i(34)=2;
g2_i(35)=3;
g2_i(36)=3;
g2_i(37)=3;
g2_i(38)=3;
g2_i(39)=3;
g2_i(40)=3;
g2_i(41)=3;
g2_i(42)=3;
g2_i(43)=3;
g2_i(44)=4;
g2_i(45)=4;
g2_i(46)=4;
g2_i(47)=4;
g2_i(48)=4;
g2_j(1)=64;
g2_j(2)=103;
g2_j(3)=106;
g2_j(4)=131;
g2_j(5)=66;
g2_j(6)=137;
g2_j(7)=150;
g2_j(8)=135;
g2_j(9)=122;
g2_j(10)=138;
g2_j(11)=164;
g2_j(12)=67;
g2_j(13)=145;
g2_j(14)=62;
g2_j(15)=75;
g2_j(16)=65;
g2_j(17)=117;
g2_j(18)=68;
g2_j(19)=159;
g2_j(20)=151;
g2_j(21)=146;
g2_j(22)=81;
g2_j(23)=149;
g2_j(24)=123;
g2_j(25)=152;
g2_j(26)=165;
g2_j(27)=79;
g2_j(28)=118;
g2_j(29)=82;
g2_j(30)=160;
g2_j(31)=121;
g2_j(32)=124;
g2_j(33)=163;
g2_j(34)=166;
g2_j(35)=1;
g2_j(36)=7;
g2_j(37)=85;
g2_j(38)=8;
g2_j(39)=99;
g2_j(40)=91;
g2_j(41)=92;
g2_j(42)=105;
g2_j(43)=106;
g2_j(44)=51;
g2_j(45)=116;
g2_j(46)=65;
g2_j(47)=117;
g2_j(48)=121;
g2_v(1)=params(5)*T(12);
g2_v(2)=g2_v(1);
g2_v(3)=y(5)*params(5)*getPowerDeriv(y(8),1+params(6),2);
g2_v(4)=(-(params(1)*params(3)*exp(y(12))*T(7)));
g2_v(5)=g2_v(4);
g2_v(6)=(-(params(1)*params(3)*exp(y(12))*T(9)));
g2_v(7)=g2_v(6);
g2_v(8)=(-(params(1)*T(2)*params(3)*exp(y(12))));
g2_v(9)=g2_v(8);
g2_v(10)=(-(params(1)*(T(2)*params(3)*exp(y(12))+params(3)*exp(y(12))*T(14))));
g2_v(11)=g2_v(10);
g2_v(12)=(-(params(1)*T(3)*(-(exp(y(9))*exp(y(12))))/T(8)));
g2_v(13)=g2_v(12);
g2_v(14)=(-(params(1)*(1-params(4))*T(7)));
g2_v(15)=g2_v(14);
g2_v(16)=(-(params(1)*T(3)*T(7)));
g2_v(17)=g2_v(16);
g2_v(18)=(-(params(1)*(params(3)*exp(y(12))*y(10)*T(7)+T(3)*(-(exp(y(9))*exp(y(12))*y(11)))/T(8))));
g2_v(19)=g2_v(18);
g2_v(20)=(-(params(1)*T(3)*(-((-(y(5)*exp(y(9))*exp(y(12))))*(exp(y(12))*exp(y(12))*y(11)+exp(y(12))*exp(y(12))*y(11))))/(T(8)*T(8))));
g2_v(21)=(-(params(1)*(1-params(4))*T(9)));
g2_v(22)=g2_v(21);
g2_v(23)=(-(params(1)*T(3)*T(9)));
g2_v(24)=g2_v(23);
g2_v(25)=(-(params(1)*(params(3)*exp(y(12))*y(10)*T(9)+T(3)*((-(y(5)*exp(y(9))*exp(y(12))))*T(8)-(-(y(5)*exp(y(9))*exp(y(12))))*(T(8)+T(8)))/(T(8)*T(8)))));
g2_v(26)=g2_v(25);
g2_v(27)=(-(params(1)*T(2)*(1-params(4))));
g2_v(28)=g2_v(27);
g2_v(29)=(-(params(1)*(1-params(4))*T(14)));
g2_v(30)=g2_v(29);
g2_v(31)=(-(params(1)*T(2)*T(3)));
g2_v(32)=(-(params(1)*(T(3)*T(14)+T(2)*params(3)*exp(y(12))*y(10))));
g2_v(33)=g2_v(32);
g2_v(34)=(-(params(1)*(params(3)*exp(y(12))*y(10)*T(14)+T(3)*(T(8)*(-(y(5)*exp(y(9))*exp(y(12))*y(11)))-(-(y(5)*exp(y(9))*exp(y(12))*y(11)))*(T(8)+T(8)))/(T(8)*T(8))+T(2)*params(3)*exp(y(12))*y(10)+params(3)*exp(y(12))*y(10)*T(14))));
g2_v(35)=(-(T(5)*exp(y(7))*getPowerDeriv(y(1),params(3),2)));
g2_v(36)=T(11);
g2_v(37)=g2_v(36);
g2_v(38)=(-(T(10)*T(13)));
g2_v(39)=g2_v(38);
g2_v(40)=(-T(6));
g2_v(41)=(-(T(4)*T(13)));
g2_v(42)=g2_v(41);
g2_v(43)=(-(T(4)*getPowerDeriv(y(8),1-params(3),2)));
g2_v(44)=(-exp(y(9)));
g2_v(45)=g2_v(44);
g2_v(46)=exp(y(9));
g2_v(47)=g2_v(46);
g2_v(48)=(-(exp(y(9))*(y(4)-y(5))));
g2 = sparse(g2_i,g2_j,g2_v,6,196);
end
