% Step 2: Plot impulse response functions (IRFs) replicating paper figures.
% Run this script from MATLAB; figures will be displayed in MATLAB.
cd(fileparts(mfilename('fullpath')));

% Check if model results exist; if not, run Dynare first
if ~exist('oo_', 'var') || ~isfield(oo_, 'irfs')
    if exist('dynare', 'file') ~= 2
        error('Add Dynare to the MATLAB path, e.g., addpath(''C:/dynare/7.1/matlab'').');
    end
    dynare sww_klasyczny.mod noclearall
end

close all;

%% Figure 2 replication
linewidth = 1.5;
irf_horizon=0:(numel(oo_.irfs.y_eta_b)-1);
b=zeros(size(irf_horizon));
figure(1)
plot(irf_horizon,oo_.irfs.y_eta_b,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.y_eta_g, '-g','LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.y_eta_r, '-b','LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.y_eta_q, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k');
hold on
plot(irf_horizon,(b+0.5),':k');
hold on
ylim([-0.5 1])
legend('risk premium','exogenenous spending','monetary policy','investment-specific')
title('Output')

figure(2)
plot(irf_horizon,oo_.irfs.pi_year_eta_b,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.pi_year_eta_g, '-g','LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.pi_year_eta_r, '-b','LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.pi_year_eta_q, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k');
hold on
plot(irf_horizon,(b+0.05),':k');
hold on
plot(irf_horizon,(b+0.1),':k');
hold on
ylim([-0.05 0.15])
title('Inflation')

figure(3)
plot(irf_horizon,oo_.irfs.r_year_eta_b,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.r_year_eta_g, '-g','LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.r_year_eta_r, '-b','LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.r_year_eta_q, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k');
hold on
ylim([-0.5 0.5])
title('Interest Rate')

figure(4)
plot(irf_horizon,oo_.irfs.e_eta_b,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.e_eta_g, '-g','LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.e_eta_r, '-b','LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.e_eta_q, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k');
hold on
plot(irf_horizon,(b+0.3),':k');
hold on
plot(irf_horizon,(b+0.2),':k');
hold on
plot(irf_horizon,(b+0.1),':k');
hold on
ylim([-0.1 0.4])
title('Employment')

figure(5)
plot(irf_horizon,oo_.irfs.u_eta_b,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.u_eta_g, '-g','LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.u_eta_r, '-b','LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.u_eta_q, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k');
hold on
plot(irf_horizon,(b-0.1),':k');
hold on
plot(irf_horizon,(b-0.2),':k');
hold on
plot(irf_horizon,(b-0.3),':k');
hold on
ylim([-0.4 0.1])
title('Unemployment')

figure(6)
plot(irf_horizon,oo_.irfs.y_gap_eta_b,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.y_gap_eta_g, '-g','LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.y_gap_eta_r, '-b','LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.y_gap_eta_q, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k');
hold on
plot(irf_horizon,(b+0.5),':k');
hold on
ylim([-0.5 1])
title('Output Gap')

%% Figure 3 replication
linewidth = 1.5;
irf_horizon=0:(numel(oo_.irfs.y_eta_b)-1);
b=zeros(size(irf_horizon));
figure(7)
plot(irf_horizon,oo_.irfs.y_eta_a,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.y_eta_p, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k')
hold on
plot(irf_horizon,(b+0.5),':k')
hold on
ylim([-0.5 1])
legend('productivity','price markup')
title('Output')


figure(8)
plot(irf_horizon,oo_.irfs.pi_year_eta_a,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.pi_year_eta_p, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k')
hold on
plot(irf_horizon,(b-0.1),':k')
hold on
plot(irf_horizon,(b-0.2),':k')
hold on
plot(irf_horizon,(b-0.3),':k')
hold on
ylim([-0.4 0.1])
title('Inflation')


figure(9)
plot(irf_horizon,oo_.irfs.r_year_eta_a,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.r_year_eta_p, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k')
hold on
plot(irf_horizon,(b-0.1),':k')
hold on
plot(irf_horizon,(b-0.2),':k')
ylim([-0.3 0.11])
title('Interest Rate')


figure(10)
plot(irf_horizon,oo_.irfs.e_eta_a,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.e_eta_p, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k')
hold on
plot(irf_horizon,(b-0.05),':k')
hold on
plot(irf_horizon,(b+0.05),':k')
ylim([-0.1 0.1])
title('Employment')

figure(11)
plot(irf_horizon,oo_.irfs.u_eta_a,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.u_eta_p, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k')
hold on
plot(irf_horizon,(b-0.05),':k')
hold on
plot(irf_horizon,(b+0.05),':k')
ylim([-0.1 0.1])
title('Unemployment')

figure(12)
plot(irf_horizon,oo_.irfs.y_gap_eta_a,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.y_gap_eta_p, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k')
hold on
plot(irf_horizon,(b-0.2),':k')
hold on
plot(irf_horizon,(b-0.4),':k')
hold on
plot(irf_horizon,(b-0.6),':k')
ylim([-0.8 0.2])
title('Output Gap')

%% Figure 4 replication
linewidth = 1.5;
irf_horizon=0:(numel(oo_.irfs.y_eta_b)-1);
b=zeros(size(irf_horizon));
figure(13)
plot(irf_horizon,oo_.irfs.y_eta_w,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.y_eta_s, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k')
hold on
plot(irf_horizon,(b-0.1),':k')
hold on
plot(irf_horizon,(b-0.2),':k')
ylim([-0.3 0.11])
legend('wage markup','labor supply')
title('Output')


figure(14)
plot(irf_horizon,oo_.irfs.pi_year_eta_w,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.pi_year_eta_s, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k')
hold on
plot(irf_horizon,(b+0.05),':k')
hold on
plot(irf_horizon,(b+0.1),':k')
hold on
plot(irf_horizon,(b+0.15),':k')
ylim([0 0.2])
title('Inflation')

figure(15)
plot(irf_horizon,oo_.irfs.r_year_eta_w,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.r_year_eta_s, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k')
hold on
plot(irf_horizon,(b+0.1),':k')
hold on
plot(irf_horizon,(b+0.05),':k')
ylim([-0.05 0.15])
title('Interest Rate')

figure(16)
plot(irf_horizon,oo_.irfs.e_eta_w,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.e_eta_s, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k')
hold on
plot(irf_horizon,(b-0.05),':k')
hold on
plot(irf_horizon,(b-0.15),':k')
hold on
plot(irf_horizon,(b-0.1),':k')
ylim([-0.2 0])
title('Employment')

figure(17)
plot(irf_horizon,oo_.irfs.u_eta_w,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.u_eta_s, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k')
hold on
plot(irf_horizon,(b-0.1),':k')
hold on
plot(irf_horizon,(b+0.1),':k')
ylim([-0.2 0.2])
title('Unemployment')

figure(18)
plot(irf_horizon,oo_.irfs.y_gap_eta_w,'-k', 'LineWidth',linewidth)
hold on
plot(irf_horizon,oo_.irfs.y_gap_eta_s, '-r','LineWidth',linewidth)
hold on
plot(irf_horizon,b,'-k')
hold on
plot(irf_horizon,(b+0.1),':k')
hold on
plot(irf_horizon,(b+0.05),':k')
hold on
plot(irf_horizon,(b-0.05),':k')
ylim([-0.1 0.15])
title('Output Gap')
