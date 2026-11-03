// Common measurement equations for simulation and estimation.
// robs is annual percent in the data. robs/4 is quarterly percent, like crbar and r.
// Intercepts retain the workbook calibration; sample means below are diagnostics.
// No local observations for this country; calibrated measurement equations retained.
[name = 'Observed quarterly GDP growth']
dy_obs=c_tau_bar+c_e_bar+gdp-gdp(-1);
[name = 'Observed quarterly consumption growth']
dc_obs=c_tau_bar+c_e_bar+c-c(-1);
[name = 'Observed quarterly investment growth']
di_obs=c_tau_bar+c_e_bar+i-i(-1);
[name = 'Observed quarterly inflation']
pi_obs=c_pi_bar+pi_c;
[name = 'Observed wage measurement series']
dw_obs=c_tau_bar+w-w(-1)+c_pi_bar+pi;
[name = 'Observed quarterly employment growth']
de_obs=c_e_bar+e-e(-1);
[name = 'Observed unemployment rate']
u_obs=c_u_bar+u;
[name = 'Observed annual nominal interest rate']
r_obs/4=c_r_bar+r;
[name = 'Observed demeaned relative energy price']
p_e_obs=p_e;
[name = 'Diagnostic domestic inflation']
pi_d_obs=c_pi_bar+pi;
[name = 'Diagnostic energy inflation']
pi_e_obs=c_pi_bar+pi_e;
[name = 'Observed demeaned relative food price']
p_f_obs=p_f;
[name = 'Diagnostic food inflation']
pi_f_obs=c_pi_bar+pi_f;
