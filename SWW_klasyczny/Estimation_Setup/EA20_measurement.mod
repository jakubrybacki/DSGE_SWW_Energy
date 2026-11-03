// Common measurement equations for simulation and estimation.
// robs is annual percent in the data. robs/4 is quarterly percent, like crbar and r.
// Intercepts retain the workbook calibration; sample means below are diagnostics.
// Data sample: 2009Q1 -- 2026Q2
// Sample mean dy_obs: 0.272685976620594
// Sample mean dc_obs: 0.214496489894615
// Sample mean di_obs: 0.221961345269272
// Sample mean pi_obs: 0.52165036135389
// Sample mean dw_obs: 0.591212898018239
// Sample mean de_obs: 0.154457888029896
// Sample mean u_obs: 8.96285714285714
// Sample mean r_obs: 0.96736734883474
// Source SHA256: d47204a6e6531efd7fcbd19ec06e270a19ac4c4791a670ce7b7fd9eaf2ed2e0b
[name = 'Observed quarterly GDP growth']
dy_obs=c_tau_bar+c_e_bar+y-y(-1);
[name = 'Observed quarterly consumption growth']
dc_obs=c_tau_bar+c_e_bar+c-c(-1);
[name = 'Observed quarterly investment growth']
di_obs=c_tau_bar+c_e_bar+i-i(-1);
[name = 'Observed quarterly inflation']
pi_obs=c_pi_bar+pi;
[name = 'Observed wage measurement series']
dw_obs-pi_obs=c_tau_bar+w-w(-1)-(pi-pi(-1));
[name = 'Observed quarterly employment growth']
de_obs=c_e_bar+e-e(-1);
[name = 'Observed unemployment rate']
u_obs=c_u_bar+u;
[name = 'Observed annual nominal interest rate']
r_obs/4=c_r_bar+r;
