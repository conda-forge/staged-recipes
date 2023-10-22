function T = dynamic_g1_tt(T, y, x, params, steady_state, it_)
% function T = dynamic_g1_tt(T, y, x, params, steady_state, it_)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T             [#temp variables by 1]     double  vector of temporary terms to be filled by function
%   y             [#dynamic variables by 1]  double  vector of endogenous variables in the order stored
%                                                    in M_.lead_lag_incidence; see the Manual
%   x             [nperiods by M_.exo_nbr]   double  matrix of exogenous variables (in declaration order)
%                                                    for all simulation periods
%   steady_state  [M_.endo_nbr by 1]         double  vector of steady state values
%   params        [M_.param_nbr by 1]        double  vector of parameter values in declaration order
%   it_           scalar                     double  time period for exogenous variables for which
%                                                    to evaluate the model
%
% Output:
%   T           [#temp variables by 1]       double  vector of temporary terms
%

assert(length(T) >= 14);

T = example1.dynamic_resid_tt(T, y, x, params, steady_state, it_);

T(7) = exp(y(9))/(exp(y(12))*y(11));
T(8) = exp(y(12))*y(11)*exp(y(12))*y(11);
T(9) = (-(y(5)*exp(y(9))*exp(y(12))))/T(8);
T(10) = exp(y(7))*getPowerDeriv(y(1),params(3),1);
T(11) = (-(T(5)*T(10)));
T(12) = getPowerDeriv(y(8),1+params(6),1);
T(13) = getPowerDeriv(y(8),1-params(3),1);
T(14) = (-(y(5)*exp(y(9))*exp(y(12))*y(11)))/T(8);

end
