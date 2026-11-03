function oblicz_dekompozycje_cnu
% OBLICZ_DEKOMPOZYCJE_CNU
% Oblicza wplyw udzialu energii w funkcji produkcji (cnu \in [0, 0.10])
% na dekompozycje inflacji HICP i wklad szoku marzowego (etap) w latach 2022 i 2023.

root = fileparts(fileparts(mfilename('fullpath')));
diag_dir = fullfile(root, 'diagnostyka', 'runs', 'ceny_roczne_phi15');
model_dir = fullfile(diag_dir, 'model_roczne');
table_dir = fullfile(root, 'Tabele');
if ~isfolder(table_dir), mkdir(table_dir); end

addpath('C:/dynare/7.1/matlab'); dynare_config;
cd(model_dir);

D = load(fullfile(diag_dir, 'diagnostics.mat'));
C = load(fullfile(diag_dir, 'optimizer_complete.mat'), 'S');
M_ = D.M_; oo_ = D.oo_; options_ = D.options_;
estim_params_ = C.S.estim_params_; bayestopt_ = C.S.bayestopt_;
options_.datafile = fullfile(model_dir, 'data', 'EA20', 'dane.mat');
options_.parameter_set = 'calibration';
options_.no_graph.shock_decomposition = true;
options_.nograph = true;
options_.shock_decomp.init_state = 0;

obs = readtable(fullfile(model_dir, 'data', 'EA20', 'observables.csv'));
trend = M_.params(strcmp(M_.param_names, 'cpibar'));

% Indeksy dla 2022 (Q1-Q4) i 2023 (Q1-Q4)
idx_2022 = find(startsWith(string(obs.quarter), '2022'));
idx_2023 = find(startsWith(string(obs.quarter), '2023'));

cnu_grid = [0.00, 0.01, 0.02, 0.03, 0.05, 0.08, 0.10, 0.12, 0.15, 0.20];
N = numel(cnu_grid);

results = table();

for i = 1:N
    nu = cnu_grid(i);
    mm = M_;
    mm.params(strcmp(mm.param_names, 'cnu')) = nu;
    
    [ys, pp, check] = sww_energia_w_produkcji_steadystate(oo_.steady_state, oo_.exo_steady_state, mm, options_);
    if check ~= 0
        warning('Steady state failed for nu = %.3f', nu);
        continue;
    end
    mm.params = pp;
    
    [dr, info, pp] = resol(0, mm, options_, oo_.dr, ys, oo_.exo_steady_state, oo_.exo_det_steady_state);
    if info(1) ~= 0
        warning('Resolution failed for nu = %.3f', nu);
        continue;
    end
    mm.params = pp;
    
    oox = oo_;
    oox.dr = dr;
    oox.steady_state = ys;
    
    [oox, mm] = shock_decomposition(mm, oox, options_, {'piobs'}, bayestopt_, estim_params_);
    
    z = squeeze(oox.shock_decomposition(strcmp(mm.endo_names, 'piobs'), :, :))';
    exo = mm.exo_names;
    
    etap_i = find(strcmp(exo, 'etap'));
    etaE_i = find(strcmp(exo, 'etaE'));
    etaw_i = find(strcmp(exo, 'etaw'));
    etar_i = find(strcmp(exo, 'etar'));
    etab_i = find(strcmp(exo, 'etab'));
    etaa_i = find(strcmp(exo, 'etaa'));
    
    % Sumy kwartalne w 2022
    infl_2022 = sum(obs.piobs(idx_2022));
    etap_2022 = sum(z(idx_2022, etap_i));
    etaE_2022 = sum(z(idx_2022, etaE_i));
    etaw_2022 = sum(z(idx_2022, etaw_i));
    etar_2022 = sum(z(idx_2022, etar_i));
    etab_2022 = sum(z(idx_2022, etab_i));
    etaa_2022 = sum(z(idx_2022, etaa_i));
    etap_share_2022 = (etap_2022 / infl_2022) * 100;
    
    % Sumy kwartalne w 2023
    infl_2023 = sum(obs.piobs(idx_2023));
    etap_2023 = sum(z(idx_2023, etap_i));
    etaE_2023 = sum(z(idx_2023, etaE_i));
    etaw_2023 = sum(z(idx_2023, etaw_i));
    etar_2023 = sum(z(idx_2023, etar_i));
    etab_2023 = sum(z(idx_2023, etab_i));
    etaa_2023 = sum(z(idx_2023, etaa_i));
    etap_share_2023 = (etap_2023 / infl_2023) * 100;
    
    row = table(nu, infl_2022, etap_2022, etap_share_2022, etaE_2022, etaw_2022, etar_2022, ...
                infl_2023, etap_2023, etap_share_2023, etaE_2023, etaw_2023, etar_2023, ...
                'VariableNames', {'cnu', 'Infl_2022', 'etap_2022', 'Share_etap_2022', 'etaE_2022', 'etaw_2022', 'etar_2022', ...
                                  'Infl_2023', 'etap_2023', 'Share_etap_2023', 'etaE_2023', 'etaw_2023', 'etar_2023'});
    results = [results; row]; %#ok<AGROW>
end

writetable(results, fullfile(table_dir, 'dekompozycja_cnu.csv'));
fprintf('Zapisano: %s\n', fullfile(table_dir, 'dekompozycja_cnu.csv'));
disp(results(:, {'cnu', 'Infl_2022', 'etap_2022', 'Share_etap_2022', 'etaE_2022', 'Infl_2023', 'etap_2023', 'Share_etap_2023', 'etaE_2023'}));

cd(root);
end
