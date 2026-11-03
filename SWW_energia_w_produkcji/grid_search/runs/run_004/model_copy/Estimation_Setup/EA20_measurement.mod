// Common measurement equations for simulation and estimation.
// r_obs is annual percent in the data. r_obs/4 is quarterly percent, like c_r_bar and r.
// Intercepts retain the workbook calibration; sample means below are diagnostics.
// Data sample: 2009Q1 -- 2025Q4
// Sample mean dy_obs: 0.266129780311975
// Sample mean dc_obs: 0.213158659844676
// Sample mean di_obs: 0.226554596144201
// Sample mean pi_obs: 0.510556853356593
// Sample mean dw_obs: 0.608506745899754
// Sample mean de_obs: 0.155296293489155
// Sample mean u_obs: 9.03970588235294
// Sample mean r_obs: 0.936430189411327
// Sample mean p_e_obs: -2.44708256925881e-15
// Source SHA256: 6b3d0f50bdd6ee331d650dfc8fd184a06d320d4c938db875196a3c59f8f26e57
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
