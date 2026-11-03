function step_2_validate_model()
% Step 2: Validate the SWW energy and food model against baseline energy model.
% Generates IRF plots (results/food_irf.png, food_irf.pdf) and validation metrics (results/validation.json).
% Run this function/script from MATLAB. Requires Dynare on the MATLAB path.
root = fileparts(mfilename('fullpath'));
original = pwd;
cleanup = onCleanup(@() cd(original));
cd(root);

if exist('dynare', 'file') ~= 2
    error('Add Dynare to the MATLAB path, e.g., addpath(''C:/dynare/7.1/matlab'').');
end

if ~exist('validation', 'dir'), mkdir('validation'); end
if ~exist('results', 'dir'), mkdir('results'); end

base = fullfile(fileparts(root), 'SWW_energia_w_produkcji');
refdir = fullfile(root, 'validation', 'reference');
zerodir = fullfile(root, 'validation', 'zero_food');
if ~exist(refdir, 'dir'), mkdir(refdir); end
if ~exist(zerodir, 'dir'), mkdir(zerodir); end

copyfile(fullfile(base, 'Estimation_Setup'), fullfile(refdir, 'Estimation_Setup'));
copyfile(fullfile(base, 'sww_energia_w_produkcji_steadystate.m'), refdir);
s = fileread(fullfile(base, 'sww_energia_w_produkcji.mod'));
s = strrep(s, 'stoch_simul(order=1,irf=40,irf_shocks=(eta_e),nograph,noprint);', 'stoch_simul(order=1,irf=200,nograph,noprint);');
write_text(fullfile(refdir, 'sww_energia_w_produkcji.mod'), s);

copyfile(fullfile(root, 'Estimation_Setup'), fullfile(zerodir, 'Estimation_Setup'));
copyfile(fullfile(root, 'sww_energia_zywnosc.mod'), zerodir);
copyfile(fullfile(root, 'sww_energia_zywnosc_steadystate.m'), zerodir);

run_dynare(root, 'sww_energia_zywnosc', false);
run_dynare(refdir, 'sww_energia_w_produkcji', false);
run_dynare(zerodir, 'sww_energia_zywnosc', true);
cd(root);

A = load(fullfile(refdir, 'sww_energia_w_produkcji', 'Output', 'sww_energia_w_produkcji_results.mat'));
Z = load(fullfile(zerodir, 'sww_energia_zywnosc', 'Output', 'sww_energia_zywnosc_results.mat'));
D = load(fullfile(root, 'sww_energia_zywnosc', 'Output', 'sww_energia_zywnosc_results.mat'));

fields = fieldnames(A.oo_.irfs);
err = 0;
for j = 1:numel(fields)
    err = max(err, max(abs(A.oo_.irfs.(fields{j}) - Z.oo_.irfs.(fields{j}))));
end
assert(err < 1e-7, 'Zero food model differs from baseline');

p = @(n) D.M_.params(strcmp(D.M_.param_names, n));
I = D.oo_.irfs;
shocks = cellstr(D.M_.exo_names);
identity = 0;
for j = 1:numel(shocks)
    sh = shocks{j};
    ir = @(n) I.([n '_' sh]);
    identity = max(identity, max(abs(ir('p_c') - p('c_omega_e')*ir('p_e') - p('c_omega_f')*ir('p_f'))));
    identity = max(identity, max(abs(ir('c_food') - ir('c') - ir('p_c') + ir('p_f'))));
    identity = max(identity, max(abs(ir('exports') - p('c_weight_xe')*(ir('p_e') + ir('e_tot')) - p('c_weight_xf')*(ir('p_f') + ir('c_food')))));
end
assert(identity < 1e-8);

share_error = abs(p('c_share_n') + p('c_i_y') + p('c_g_y') + p('c_share_x') - 1);
assert(share_error < 1e-12);
assert(max(abs(I.p_f_eta_f - p('c_sigma_f')*p('c_rho_f').^(0:199))) < 1e-9);

zero_effect = 0;
for n = {'c', 'gdp', 'r', 'pi_c', 'pi', 'i', 'y_gap'}
    zero_effect = max(zero_effect, max(abs(Z.oo_.irfs.([n{1} '_eta_f']))));
end
assert(zero_effect < 1e-8);

vars = {'p_f', 'pi_c', 'pi', 'r_year', 'c', 'gdp', 'c_food', 'y_gap', 'pi_year'};
T = table((0:199)', 'VariableNames', {'quarter'});
for j = 1:numel(vars)
    T.(vars{j}) = I.([vars{j} '_eta_f'])';
end
writetable(T, fullfile(root, 'results', 'food_irf.csv'));

f = figure('Visible', 'off', 'Position', [100 100 1200 800]);
tiledlayout(3, 3);
labels = {'Relative food price (%)', 'Quarterly CPI inflation (pp)', 'Domestic inflation (pp)', ...
    'Annualized policy rate (pp)', 'Consumption (%)', 'GDP (%)', ...
    'Imported food consumption (%)', 'Output gap (pp)', 'Four-quarter CPI inflation (pp)'};
for j = 1:numel(vars)
    nexttile;
    plot(0:39, T.(vars{j})(1:40), 'LineWidth', 1.6);
    yline(0, ':');
    grid on;
    title(labels{j});
    xlabel('Quarters after shock');
end
sgtitle('Global food price innovation: 5 log-percent; illustrative calibration');
exportgraphics(f, fullfile(root, 'results', 'food_irf.png'), 'Resolution', 130);
exportgraphics(f, fullfile(root, 'results', 'food_irf.pdf'), 'ContentType', 'vector');
close(f);

report = struct('zero_food_max_irf_difference', err, 'zero_food_aggregate_effect', zero_effect, ...
    'identity_max_error', identity, 'steady_state_share_error', share_error, ...
    'common_irf_series_compared', numel(fields), 'irf_horizon', 200, ...
    'unstable_roots', sum(abs(D.oo_.dr.eigval) > 1 + 1e-6), ...
    'forward_variables', D.M_.nfwrd + D.M_.nboth, 'estimated', false);
for j = 1:numel(vars)
    report.([vars{j} '_impact']) = T.(vars{j})(1);
end
write_text(fullfile(root, 'results', 'validation.json'), jsonencode(report, PrettyPrint=true));
disp(report);
end

function run_dynare(folder, stem, zero)
cd(folder);
if zero
    dynare([stem '.mod'], '-DFOOD_CONSUMPTION_SHARE=0');
else
    dynare([stem '.mod']);
end
end

function write_text(path, s)
fid = fopen(path, 'w');
assert(fid >= 0);
c = onCleanup(@() fclose(fid));
fprintf(fid, '%s', s);
end
