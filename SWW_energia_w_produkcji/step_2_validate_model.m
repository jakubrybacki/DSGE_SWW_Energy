% Step 2: Validate the SWW energy in production model.
% Checks structural identities, shock normalizations, and tests zero-energy nesting against SWW_klasyczny.
% Requires Dynare on the MATLAB path.
test_source = fileparts(mfilename('fullpath'));
cd(test_source);

if exist('dynare', 'file') ~= 2
    error('Add Dynare to the MATLAB path, e.g., addpath(''C:/dynare/7.1/matlab'').');
end

test_work = fullfile(test_source, 'walidacja');
if ~exist(test_work, 'dir'), mkdir(test_work); end

test_results_path = fullfile(test_source, 'sww_energia_w_produkcji', 'Output', 'sww_energia_w_produkcji_results.mat');
if ~exist(test_results_path, 'file')
    fprintf('Results file not found. Running step_1_run_model first...\n');
    step_1_run_model;
end

test_default = load(test_results_path);
test_irf = test_default.oo_.irfs;
test_tol = 1e-7;
test_sigma = test_default.M_.params(strcmp(test_default.M_.param_names,'c_sigma_e'));
assert(abs(test_irf.p_e_eta_e(1)-test_sigma)<test_tol, 'Energy shock normalization failure');
assert(all(cellfun(@(x) all(isfinite(x(:))),struct2cell(test_irf))), 'Non-finite IRFs detected');
test_par = @(name) test_default.M_.params(strcmp(test_default.M_.param_names,name));
test_nu = test_par('c_nu');
test_omega = test_par('c_omega_e');
test_alpha = test_par('c_alpha');
test_phi = test_par('c_psi_p');
assert(test_nu>0 && test_nu<1-test_alpha && test_omega>0 && test_omega<1);
assert(test_par('c_c_y')>0 && test_par('c_share_gdp')>0);
assert(abs(test_par('c_share_n')+test_par('c_i_y')+test_par('c_g_y')+test_par('c_share_x')-1)<test_tol);
assert(max(abs(test_irf.y_eta_e-test_phi*(test_alpha*test_irf.k_eta_e+ ...
    (1-test_alpha-test_nu)*test_irf.n_eta_e+test_nu*test_irf.e_n_eta_e)))<test_tol);
assert(max(abs(test_irf.e_n_eta_e-test_irf.mc_eta_e-test_irf.y_eta_e/test_phi+test_irf.p_e_eta_e))<test_tol);
assert(max(abs(test_irf.gdp_eta_e-(test_irf.y_eta_e-test_nu*test_irf.e_n_eta_e)/(1-test_nu)))<test_tol);
assert(max(abs(test_irf.pi_c_eta_e-test_irf.pi_eta_e-test_omega* ...
    (test_irf.p_e_eta_e-[0 test_irf.p_e_eta_e(1:end-1)])))<test_tol);
assert(max(abs(test_irf.exports_eta_e-test_irf.p_e_eta_e-test_irf.e_tot_eta_e))<test_tol);
assert(max(abs(test_irf.y_eta_e-test_par('c_share_n')*test_irf.c_n_eta_e- ...
    test_par('c_i_y')*test_irf.i_eta_e-test_par('c_v_y')*test_irf.v_eta_e- ...
    test_par('c_share_x')*test_irf.exports_eta_e))<test_tol);
test_impact = struct('p_e',test_irf.p_e_eta_e(1),'gdp',test_irf.gdp_eta_e(1), ...
    'consumption',test_irf.c_eta_e(1),'energy_firms',test_irf.e_n_eta_e(1), ...
    'inflation_CPI',test_irf.pi_c_eta_e(1),'inflation_domestic',test_irf.pi_eta_e(1));

% Compare all economic IRFs with the unmodified baseline at zero energy shares.
classic_source = fullfile(test_source, '..', 'SWW_klasyczny');
test_baseline_text = fileread(fullfile(classic_source, 'sww_klasyczny.mod'));
test_baseline_text = strrep(test_baseline_text, 'Estimation_Setup/', [strrep(fullfile(classic_source, 'Estimation_Setup'), '\', '/') '/']);
test_baseline_text = regexprep(test_baseline_text, 'stoch_simul\(periods\s*=\s*1000,\s*irf\s*=\s*40\);', 'stoch_simul(order=1,irf=40,nograph,noprint);');
test_fid = fopen(fullfile(test_work, 'baseline_check.mod'), 'w');
assert(test_fid >= 0); fwrite(test_fid, test_baseline_text); fclose(test_fid);

% Create zero-energy calibration matching baseline parameters with zero shares
calib_mod = fileread(fullfile(classic_source, 'Estimation_Setup', 'EA20_calibration.mod'));
calib_mod = [calib_mod sprintf('\n\n// Zero energy shares for nesting validation\nc_nu = 0;\nc_omega_e = 0;\nc_rho_e = 0.8;\nc_sigma_e = 10;\nc_alpha_n = (1-c_alpha)-c_nu;\nc_share_en = c_nu;\nc_share_gdp = (1-c_share_en);\nc_c_y = (((1-c_i_y)-c_g_y)-c_share_en);\nc_share_n = ((1-c_omega_e)*c_c_y);\nc_share_ce = (c_omega_e*c_c_y);\nc_share_x = (c_share_en+c_share_ce);\nc_weight_en = 0;\nc_weight_ce = 0;\n')];
test_fid = fopen(fullfile(test_work, 'zero_calib.mod'), 'w');
assert(test_fid >= 0); fwrite(test_fid, calib_mod); fclose(test_fid);

test_energy_text = fileread(fullfile(test_source, 'sww_energia_w_produkcji.mod'));
calib_path = strrep(fullfile(test_work, 'zero_calib.mod'), '\', '/');
shocks_path = strrep(fullfile(test_source, 'Estimation_Setup', 'EA20_shocks.mod'), '\', '/');
meas_path = strrep(fullfile(test_source, 'Estimation_Setup', 'EA20_measurement.mod'), '\', '/');
test_energy_text = strrep(test_energy_text, '@#define CALIBRATION_FILE = "Estimation_Setup/" + COUNTRY + "_calibration.mod"', sprintf('@#define CALIBRATION_FILE = "%s"', calib_path));
test_energy_text = strrep(test_energy_text, '@#define SHOCKS_FILE = "Estimation_Setup/" + COUNTRY + "_shocks.mod"', sprintf('@#define SHOCKS_FILE = "%s"', shocks_path));
test_energy_text = strrep(test_energy_text, '@#define MEASUREMENT_EQ_FILE = "Estimation_Setup/" + COUNTRY + "_measurement.mod"', sprintf('@#define MEASUREMENT_EQ_FILE = "%s"', meas_path));
test_energy_text = regexprep(test_energy_text, 'stoch_simul\(order=1,irf=40,irf_shocks=\(eta_e\),nograph,noprint\)[\s\S]*?;', 'stoch_simul(order=1,irf=40,nograph,noprint);');
test_fid = fopen(fullfile(test_work, 'zero_energy_check.mod'), 'w');
assert(test_fid >= 0); fwrite(test_fid, test_energy_text); fclose(test_fid);

cd(test_work);
dynare baseline_check.mod noclearall;
dynare zero_energy_check.mod noclearall;
test_base = load(fullfile(test_work, 'baseline_check', 'Output', 'baseline_check_results.mat'));
test_zero = load(fullfile(test_work, 'zero_energy_check', 'Output', 'zero_energy_check_results.mat'));

test_variables = {'c','r','pi','i','q','r_k','y','v','k','n','mc','w','z','u', ...
    'e','u_n','l','k_bar','y_gap','c_f','r_f','inv_f','q_f','r_k_f','v_f','k_f','n_f', ...
    'w_f','z_f','e_f','k_bar_f','y_f','dy_obs','dc_obs','di_obs','pi_obs','de_obs','u_obs','r_obs'};
test_shocks = {'eta_b','eta_q','eta_g','eta_a','eta_p','eta_s','eta_w','eta_r'};
test_max_error = 0;
for test_vi=1:numel(test_variables)
    for test_si=1:numel(test_shocks)
        test_field=[test_variables{test_vi} '_' test_shocks{test_si}];
        test_difference=max(abs(test_base.oo_.irfs.(test_field)-test_zero.oo_.irfs.(test_field)));
        test_max_error=max(test_max_error,test_difference);
    end
end
assert(test_max_error<test_tol,'Zero-energy model does not reproduce baseline');
test_report=sprintf(['PASS: structural identities and finite IRFs.\n' ...
    'PASS: zero-energy recovery; maximum IRF difference = %.12g.\n' ...
    'Compared %d variables x %d original shocks.\n' ...
    'dw_obs excluded intentionally: contemporaneous nominal wage identity corrected.\n' ...
    'Illustrative energy shock impact (log-percent quantities; quarterly pp inflation):\n' ...
    'p_e=%.8f; GDP=%.8f; C=%.8f; En=%.8f; pi_c=%.8f; piD=%.8f.\n'], ...
    test_max_error,numel(test_variables),numel(test_shocks),test_impact.p_e, ...
    test_impact.gdp,test_impact.consumption,test_impact.energy_firms, ...
    test_impact.inflation_CPI,test_impact.inflation_domestic);
test_fid=fopen(fullfile(test_work,'validation_report.txt'),'w');
fwrite(test_fid,test_report); fclose(test_fid);
disp(test_report);
cd(test_source);
% Restore the default energy model results for subsequent interactive use.
M_=test_default.M_; oo_=test_default.oo_; options_=test_default.options_;
