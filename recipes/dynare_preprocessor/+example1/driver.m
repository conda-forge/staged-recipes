%
% Status : main Dynare file
%
% Warning : this file is generated automatically by Dynare
%           from model file (.mod)

if ~isoctave && matlab_ver_less_than('8.6')
    clear all
else
    clearvars -global
    clear_persistent_variables(fileparts(which('dynare')), false)
end
tic0 = tic;
% Define global variables.
global M_ options_ oo_ estim_params_ bayestopt_ dataset_ dataset_info estimation_info ys0_ ex0_
options_ = [];
M_.fname = 'example1';
M_.dynare_version = '6-unstable';
oo_.dynare_version = '6-unstable';
options_.dynare_version = '6-unstable';
%
% Some global variables initialization
%
global_initialization;
M_.exo_names = cell(2,1);
M_.exo_names_tex = cell(2,1);
M_.exo_names_long = cell(2,1);
M_.exo_names(1) = {'e'};
M_.exo_names_tex(1) = {'e'};
M_.exo_names_long(1) = {'e'};
M_.exo_names(2) = {'u'};
M_.exo_names_tex(2) = {'u'};
M_.exo_names_long(2) = {'u'};
M_.endo_names = cell(6,1);
M_.endo_names_tex = cell(6,1);
M_.endo_names_long = cell(6,1);
M_.endo_names(1) = {'y'};
M_.endo_names_tex(1) = {'y'};
M_.endo_names_long(1) = {'y'};
M_.endo_names(2) = {'c'};
M_.endo_names_tex(2) = {'c'};
M_.endo_names_long(2) = {'c'};
M_.endo_names(3) = {'k'};
M_.endo_names_tex(3) = {'k'};
M_.endo_names_long(3) = {'k'};
M_.endo_names(4) = {'a'};
M_.endo_names_tex(4) = {'a'};
M_.endo_names_long(4) = {'a'};
M_.endo_names(5) = {'h'};
M_.endo_names_tex(5) = {'h'};
M_.endo_names_long(5) = {'h'};
M_.endo_names(6) = {'b'};
M_.endo_names_tex(6) = {'b'};
M_.endo_names_long(6) = {'b'};
M_.endo_partitions = struct();
M_.param_names = cell(7,1);
M_.param_names_tex = cell(7,1);
M_.param_names_long = cell(7,1);
M_.param_names(1) = {'beta'};
M_.param_names_tex(1) = {'beta'};
M_.param_names_long(1) = {'beta'};
M_.param_names(2) = {'rho'};
M_.param_names_tex(2) = {'rho'};
M_.param_names_long(2) = {'rho'};
M_.param_names(3) = {'alpha'};
M_.param_names_tex(3) = {'alpha'};
M_.param_names_long(3) = {'alpha'};
M_.param_names(4) = {'delta'};
M_.param_names_tex(4) = {'delta'};
M_.param_names_long(4) = {'delta'};
M_.param_names(5) = {'theta'};
M_.param_names_tex(5) = {'theta'};
M_.param_names_long(5) = {'theta'};
M_.param_names(6) = {'psi'};
M_.param_names_tex(6) = {'psi'};
M_.param_names_long(6) = {'psi'};
M_.param_names(7) = {'tau'};
M_.param_names_tex(7) = {'tau'};
M_.param_names_long(7) = {'tau'};
M_.param_partitions = struct();
M_.exo_det_nbr = 0;
M_.exo_nbr = 2;
M_.endo_nbr = 6;
M_.param_nbr = 7;
M_.orig_endo_nbr = 6;
M_.aux_vars = [];
M_.Sigma_e = zeros(2, 2);
M_.Correlation_matrix = eye(2, 2);
M_.H = 0;
M_.Correlation_matrix_ME = 1;
M_.sigma_e_is_diagonal = true;
M_.det_shocks = [];
M_.surprise_shocks = [];
M_.learnt_shocks = [];
M_.learnt_endval = [];
M_.heteroskedastic_shocks.Qvalue_orig = [];
M_.heteroskedastic_shocks.Qscale_orig = [];
options_.linear = false;
options_.block = false;
options_.bytecode = false;
options_.use_dll = false;
options_.ramsey_policy = false;
options_.discretionary_policy = false;
M_.nonzero_hessian_eqs = [1 2 3 4];
M_.hessian_eq_zero = isempty(M_.nonzero_hessian_eqs);
M_.eq_nbr = 6;
M_.ramsey_orig_eq_nbr = 0;
M_.ramsey_orig_endo_nbr = 0;
M_.set_auxiliary_variables = exist(['./+' M_.fname '/set_auxiliary_variables.m'], 'file') == 2;
M_.epilogue_names = {};
M_.epilogue_var_list_ = {};
M_.orig_maximum_endo_lag = 1;
M_.orig_maximum_endo_lead = 1;
M_.orig_maximum_exo_lag = 0;
M_.orig_maximum_exo_lead = 0;
M_.orig_maximum_exo_det_lag = 0;
M_.orig_maximum_exo_det_lead = 0;
M_.orig_maximum_lag = 1;
M_.orig_maximum_lead = 1;
M_.orig_maximum_lag_with_diffs_expanded = 1;
M_.lead_lag_incidence = [
 0 4 10;
 0 5 11;
 1 6 0;
 2 7 0;
 0 8 0;
 3 9 12;]';
M_.nstatic = 1;
M_.nfwrd   = 2;
M_.npred   = 2;
M_.nboth   = 1;
M_.nsfwrd   = 3;
M_.nspred   = 3;
M_.ndynamic   = 5;
M_.dynamic_tmp_nbr = [6; 8; 0; 0; ];
M_.equations_tags = {
  1 , 'name' , '1' ;
  2 , 'name' , 'k' ;
  3 , 'name' , 'y' ;
  4 , 'name' , '4' ;
  5 , 'name' , 'a' ;
  6 , 'name' , 'b' ;
};
M_.mapping.y.eqidx = [1 2 3 4 ];
M_.mapping.c.eqidx = [1 2 4 ];
M_.mapping.k.eqidx = [2 3 4 ];
M_.mapping.a.eqidx = [3 5 6 ];
M_.mapping.h.eqidx = [1 3 ];
M_.mapping.b.eqidx = [2 4 5 6 ];
M_.mapping.e.eqidx = [5 ];
M_.mapping.u.eqidx = [6 ];
M_.static_and_dynamic_models_differ = false;
M_.has_external_function = false;
M_.block_structure.time_recursive = false;
M_.block_structure.block(1).Simulation_Type = 6;
M_.block_structure.block(1).endo_nbr = 2;
M_.block_structure.block(1).mfs = 2;
M_.block_structure.block(1).equation = [ 5 6];
M_.block_structure.block(1).variable = [ 4 6];
M_.block_structure.block(1).is_linear = true;
M_.block_structure.block(1).NNZDerivatives = 6;
M_.block_structure.block(2).Simulation_Type = 8;
M_.block_structure.block(2).endo_nbr = 4;
M_.block_structure.block(2).mfs = 4;
M_.block_structure.block(2).equation = [ 3 4 1 2];
M_.block_structure.block(2).variable = [ 5 3 1 2];
M_.block_structure.block(2).is_linear = false;
M_.block_structure.block(2).NNZDerivatives = 14;
M_.block_structure.block(1).g1_sparse_rowval = int32([1 2 ]);
M_.block_structure.block(1).g1_sparse_colval = int32([1 2 ]);
M_.block_structure.block(1).g1_sparse_colptr = int32([1 2 3 ]);
M_.block_structure.block(2).g1_sparse_rowval = int32([1 2 1 3 2 4 1 2 3 2 3 4 4 4 ]);
M_.block_structure.block(2).g1_sparse_colval = int32([2 2 5 5 6 6 7 7 7 8 8 8 11 12 ]);
M_.block_structure.block(2).g1_sparse_colptr = int32([1 1 3 3 3 5 7 10 13 13 13 14 15 ]);
M_.block_structure.variable_reordered = [ 4 6 5 3 1 2];
M_.block_structure.equation_reordered = [ 5 6 3 4 1 2];
M_.block_structure.incidence(1).lead_lag = -1;
M_.block_structure.incidence(1).sparse_IM = [
 3 3;
 4 3;
 5 4;
 5 6;
 6 4;
 6 6;
];
M_.block_structure.incidence(2).lead_lag = 0;
M_.block_structure.incidence(2).sparse_IM = [
 1 1;
 1 2;
 1 5;
 2 2;
 2 3;
 2 6;
 3 1;
 3 4;
 3 5;
 4 1;
 4 2;
 4 3;
 4 6;
 5 4;
 6 6;
];
M_.block_structure.incidence(3).lead_lag = 1;
M_.block_structure.incidence(3).sparse_IM = [
 2 1;
 2 2;
 2 6;
];
M_.block_structure.dyn_tmp_nbr = 6;
M_.state_var = [4 6 3 ];
M_.maximum_lag = 1;
M_.maximum_lead = 1;
M_.maximum_endo_lag = 1;
M_.maximum_endo_lead = 1;
oo_.steady_state = zeros(6, 1);
M_.maximum_exo_lag = 0;
M_.maximum_exo_lead = 0;
oo_.exo_steady_state = zeros(2, 1);
M_.params = NaN(7, 1);
M_.endo_trends = struct('deflator', cell(6, 1), 'log_deflator', cell(6, 1), 'growth_factor', cell(6, 1), 'log_growth_factor', cell(6, 1));
M_.NNZDerivatives = [26; 48; -1; ];
M_.dynamic_g1_sparse_rowval = int32([3 4 5 6 5 6 1 3 4 1 2 4 2 4 3 5 1 3 2 4 6 2 2 2 5 6 ]);
M_.dynamic_g1_sparse_colval = int32([3 3 4 4 6 6 7 7 7 8 8 8 9 9 10 10 11 11 12 12 12 13 14 18 19 20 ]);
M_.dynamic_g1_sparse_colptr = int32([1 1 1 3 5 5 7 10 13 15 17 19 22 23 24 24 24 24 25 26 27 ]);
M_.dynamic_g2_sparse_indices = int32([1 8 11 ;
1 11 11 ;
2 13 8 ;
2 13 14 ;
2 13 12 ;
2 13 18 ;
2 8 14 ;
2 8 9 ;
2 8 12 ;
2 8 18 ;
2 14 14 ;
2 14 9 ;
2 14 12 ;
2 14 18 ;
2 9 12 ;
2 9 18 ;
2 12 12 ;
2 12 18 ;
2 18 18 ;
3 3 3 ;
3 3 10 ;
3 3 11 ;
3 10 10 ;
3 10 11 ;
3 11 11 ;
4 7 12 ;
4 8 12 ;
4 12 12 ;
]);
M_.lhs = {
'c*theta*h^(1+psi)'; 
'k'; 
'y'; 
'k'; 
'a'; 
'b'; 
};
M_.static_tmp_nbr = [4; 0; 0; 0; ];
M_.block_structure_stat.block(1).Simulation_Type = 6;
M_.block_structure_stat.block(1).endo_nbr = 2;
M_.block_structure_stat.block(1).mfs = 2;
M_.block_structure_stat.block(1).equation = [ 5 6];
M_.block_structure_stat.block(1).variable = [ 6 4];
M_.block_structure_stat.block(2).Simulation_Type = 6;
M_.block_structure_stat.block(2).endo_nbr = 4;
M_.block_structure_stat.block(2).mfs = 4;
M_.block_structure_stat.block(2).equation = [ 1 2 3 4];
M_.block_structure_stat.block(2).variable = [ 2 3 5 1];
M_.block_structure_stat.variable_reordered = [ 6 4 2 3 5 1];
M_.block_structure_stat.equation_reordered = [ 5 6 1 2 3 4];
M_.block_structure_stat.incidence.sparse_IM = [
 1 1;
 1 2;
 1 5;
 2 1;
 2 3;
 2 6;
 3 1;
 3 3;
 3 4;
 3 5;
 4 1;
 4 2;
 4 3;
 4 6;
 5 4;
 5 6;
 6 4;
 6 6;
];
M_.block_structure_stat.tmp_nbr = 5;
M_.block_structure_stat.block(1).g1_sparse_rowval = int32([1 2 1 2 ]);
M_.block_structure_stat.block(1).g1_sparse_colval = int32([1 1 2 2 ]);
M_.block_structure_stat.block(1).g1_sparse_colptr = int32([1 3 5 ]);
M_.block_structure_stat.block(2).g1_sparse_rowval = int32([1 4 2 3 4 1 3 1 2 3 4 ]);
M_.block_structure_stat.block(2).g1_sparse_colval = int32([1 1 2 2 2 3 3 4 4 4 4 ]);
M_.block_structure_stat.block(2).g1_sparse_colptr = int32([1 3 6 8 12 ]);
M_.static_g1_sparse_rowval = int32([1 2 3 4 1 4 2 3 4 3 5 6 1 3 2 4 5 6 ]);
M_.static_g1_sparse_colval = int32([1 1 1 1 2 2 3 3 3 4 4 4 5 5 6 6 6 6 ]);
M_.static_g1_sparse_colptr = int32([1 5 7 10 13 15 19 ]);
M_.params(3) = 0.36;
alpha = M_.params(3);
M_.params(2) = 0.95;
rho = M_.params(2);
M_.params(7) = 0.025;
tau = M_.params(7);
M_.params(1) = 0.99;
beta = M_.params(1);
M_.params(4) = 0.025;
delta = M_.params(4);
M_.params(6) = 0;
psi = M_.params(6);
M_.params(5) = 2.95;
theta = M_.params(5);
phi   = 0.1;
%
% INITVAL instructions
%
options_.initval_file = false;
oo_.steady_state(1) = 1.08068253095672;
oo_.steady_state(2) = 0.80359242014163;
oo_.steady_state(5) = 0.29175631001732;
oo_.steady_state(3) = 11.08360443260358;
oo_.steady_state(4) = 0;
oo_.steady_state(6) = 0;
oo_.exo_steady_state(1) = 0;
oo_.exo_steady_state(2) = 0;
if M_.exo_nbr > 0
	oo_.exo_simul = ones(M_.maximum_lag,1)*oo_.exo_steady_state';
end
if M_.exo_det_nbr > 0
	oo_.exo_det_simul = ones(M_.maximum_lag,1)*oo_.exo_det_steady_state';
end
%
% SHOCKS instructions
%
M_.exo_det_length = 0;
M_.Sigma_e(1, 1) = (0.009)^2;
M_.Sigma_e(2, 2) = (0.009)^2;
M_.Sigma_e(1, 2) = 0.009*0.009*phi;
M_.Sigma_e(2, 1) = M_.Sigma_e(1, 2);
M_.sigma_e_is_diagonal = 0;
options_.order = 2;
var_list_ = {};
[info, oo_, options_, M_] = stoch_simul(M_, options_, oo_, var_list_);


oo_.time = toc(tic0);
disp(['Total computing time : ' dynsec2hms(oo_.time) ]);
if ~exist([M_.dname filesep 'Output'],'dir')
    mkdir(M_.dname,'Output');
end
save([M_.dname filesep 'Output' filesep 'example1_results.mat'], 'oo_', 'M_', 'options_');
if exist('estim_params_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'example1_results.mat'], 'estim_params_', '-append');
end
if exist('bayestopt_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'example1_results.mat'], 'bayestopt_', '-append');
end
if exist('dataset_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'example1_results.mat'], 'dataset_', '-append');
end
if exist('estimation_info', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'example1_results.mat'], 'estimation_info', '-append');
end
if exist('dataset_info', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'example1_results.mat'], 'dataset_info', '-append');
end
if exist('oo_recursive_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'example1_results.mat'], 'oo_recursive_', '-append');
end
if exist('options_mom_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'example1_results.mat'], 'options_mom_', '-append');
end
if ~isempty(lastwarn)
  disp('Note: warning(s) encountered in MATLAB/Octave code')
end
