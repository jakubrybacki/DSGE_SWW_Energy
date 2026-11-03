// SWW classic model. Calibration source: ../Calibrations.xlsx.
// Generate inputs: python calibration/generate_mod_inputs.py --country EA20
@#ifndef COUNTRY
@#define COUNTRY = "EA20"
@#endif
@#define CALIBRATION_FILE = "Estimation_Setup/" + COUNTRY + "_calibration.mod"
@#define MEASUREMENT_EQ_FILE = "Estimation_Setup/" + COUNTRY + "_measurement.mod"
@#define SHOCKS_FILE = "Estimation_Setup/" + COUNTRY + "_shocks.mod"

var
    c ${\mathrm{c}}$ (long_name = 'Aggregate consumption')
    r ${\mathrm{r}}$ (long_name = 'Quarterly nominal interest rate')
    pi ${\pi}$ (long_name = 'Domestic goods inflation')
    i ${\mathrm{i}}$ (long_name = 'Investment')
    q ${\mathrm{q}}$ (long_name = 'Value of installed capital')
    r_k ${r^{k}}$ (long_name = 'Rental rate of capital')
    y ${\mathrm{y}}$ (long_name = 'Gross domestic output')
    v ${\mathrm{v}}$ (long_name = 'Capital utilization')
    k ${\mathrm{k}}$ (long_name = 'Capital services')
    n ${\mathrm{n}}$ (long_name = 'Hours worked')
    mc ${\mathrm{mc}}$ (long_name = 'Real marginal cost')
    w ${\mathrm{w}}$ (long_name = 'Real wage in domestic goods')
    z ${\mathrm{z}}$ (long_name = 'Smoothed consumption trend')
    u ${\mathrm{u}}$ (long_name = 'Unemployment rate deviation')
    e ${\mathrm{e}}$ (long_name = 'Employment')
    u_n ${u^{n}}$ (long_name = 'Natural unemployment')
    l ${\mathrm{l}}$ (long_name = 'Labour force')
    k_bar ${\bar{k}}$ (long_name = 'Installed capital stock')
    y_gap ${y^{gap}}$ (long_name = 'Output gap')
    c_f ${c^{f}}$ (long_name = 'Aggregate consumption under flexible prices')
    r_f ${r^{f}}$ (long_name = 'Real consumption interest rate under flexible prices')
    inv_f ${i^{f}}$ (long_name = 'Investment under flexible prices')
    q_f ${q^{f}}$ (long_name = 'Value of installed capital under flexible prices')
    r_k_f ${r^{k,f}}$ (long_name = 'Rental rate of capital under flexible prices')
    v_f ${v^{f}}$ (long_name = 'Capital utilization under flexible prices')
    k_f ${k^{f}}$ (long_name = 'Capital services under flexible prices')
    n_f ${n^{f}}$ (long_name = 'Hours worked under flexible prices')
    w_f ${w^{f}}$ (long_name = 'Real wage in domestic goods under flexible prices')
    z_f ${z^{f}}$ (long_name = 'Smoothed consumption trend under flexible prices')
    e_f ${e^{f}}$ (long_name = 'Employment under flexible prices')
    k_bar_f ${\bar{k}^{f}}$ (long_name = 'Installed capital stock under flexible prices')
    y_f ${y^{f}}$ (long_name = 'Gross domestic output under flexible prices')
    epsilon_b ${\epsilon_{b}}$ (long_name = 'Risk premium shock process')
    epsilon_q ${\epsilon_{q}}$ (long_name = 'Investment efficiency shock process')
    epsilon_g ${\epsilon_{g}}$ (long_name = 'Government spending shock process')
    epsilon_a ${\epsilon_{a}}$ (long_name = 'Technology shock process')
    epsilon_p ${\epsilon_{p}}$ (long_name = 'Price markup shock process')
    epsilon_s ${\epsilon_{s}}$ (long_name = 'Labour supply shock process')
    epsilon_w ${\epsilon_{w}}$ (long_name = 'Wage markup shock process')
    epsilon_r ${\epsilon_{r}}$ (long_name = 'Monetary policy shock process')
    dy_obs ${\Delta y^{obs}}$ (long_name = 'Observed quarterly GDP growth')
    dc_obs ${\Delta c^{obs}}$ (long_name = 'Observed quarterly consumption growth')
    di_obs ${\Delta i^{obs}}$ (long_name = 'Observed quarterly investment growth')
    pi_obs ${\pi^{obs}}$ (long_name = 'Observed quarterly inflation')
    dw_obs ${\Delta w^{obs}}$ (long_name = 'Observed wage measurement series')
    de_obs ${\Delta e^{obs}}$ (long_name = 'Observed quarterly employment growth')
    u_obs ${u^{obs}}$ (long_name = 'Observed unemployment rate')
    r_obs ${r^{obs}}$ (long_name = 'Observed annual nominal interest rate')
    r_year ${r^{year}}$ (long_name = 'Annualized nominal interest rate')
    pi_year ${\pi^{year}}$ (long_name = 'Four quarter consumption inflation')
;

varexo
    eta_b ${\eta_{b}}$ (long_name = 'Risk premium innovation')
    eta_q ${\eta_{q}}$ (long_name = 'Investment efficiency innovation')
    eta_g ${\eta_{g}}$ (long_name = 'Government spending innovation')
    eta_a ${\eta_{a}}$ (long_name = 'Technology innovation')
    eta_p ${\eta_{p}}$ (long_name = 'Price markup innovation')
    eta_s ${\eta_{s}}$ (long_name = 'Labour supply innovation')
    eta_w ${\eta_{w}}$ (long_name = 'Wage markup innovation')
    eta_r ${\eta_{r}}$ (long_name = 'Monetary policy innovation')
;

parameters
    c_gov_gdp ${g^{GDP}}$ (long_name = 'Government expenditure to GDP ratio')
    c_h ${h}$ (long_name = 'External consumption habit')
    c_tau ${\tau}$ (long_name = 'Gross trend growth')
    c_beta ${\beta}$ (long_name = 'Discount factor')
    c_phi ${\varphi}$ (long_name = 'Investment adjustment cost curvature')
    c_delta ${\delta}$ (long_name = 'Capital depreciation rate')
    c_psi_p ${\psi_{p}}$ (long_name = 'Price markup and fixed cost factor')
    c_alpha ${\alpha}$ (long_name = 'Capital production elasticity')
    c_gamma_p ${\gamma_{p}}$ (long_name = 'Price indexation')
    c_theta_p ${\theta_{p}}$ (long_name = 'Calvo price rigidity')
    c_eps_p ${\epsilon_{p}}$ (long_name = 'Price aggregator curvature')
    c_gamma_w ${\gamma_{w}}$ (long_name = 'Wage indexation')
    c_theta_w ${\theta_{w}}$ (long_name = 'Calvo wage rigidity')
    c_eps_w ${\epsilon_{w}}$ (long_name = 'Wage aggregator curvature')
    c_omega ${\omega}$ (long_name = 'Inverse labour supply elasticity')
    c_v ${v}$ (long_name = 'Consumption trend adjustment')
    c_psi ${\psi}$ (long_name = 'Capital utilization cost parameter')
    c_rho_intr ${\rho_{r}}$ (long_name = 'Interest rate smoothing')
    c_r_pi ${r_{\pi}}$ (long_name = 'Inflation response in policy rule')
    c_r_y ${r_{y}}$ (long_name = 'Output gap response in policy rule')
    c_r_dy ${r_{\Delta y}}$ (long_name = 'Output gap growth response')
    c_theta_e ${\theta_{e}}$ (long_name = 'Employment adjustment rigidity')
    c_r_k ${r^{k}}$ (long_name = 'Steady state capital rental rate')
    c_c_y ${c_{y}}$ (long_name = 'Consumption to output ratio')
    c_i_y ${i_{y}}$ (long_name = 'Investment to output ratio')
    c_v_y ${v_{y}}$ (long_name = 'Utilization cost coefficient')
    c_g_y ${g_{y}}$ (long_name = 'Government expenditure to output ratio')
    c_k_y ${k_{y}}$ (long_name = 'Capital to output ratio')
    c_tau_bar ${\bar{\tau}}$ (long_name = 'Quarterly productivity trend in percent')
    c_pi ${\pi}$ (long_name = 'Gross steady state inflation')
    c_pi_bar ${\bar{\pi}}$ (long_name = 'Quarterly trend inflation in percent')
    c_r_bar ${\bar{r}}$ (long_name = 'Quarterly steady state nominal rate')
    c_u_bar ${\bar{u}}$ (long_name = 'Steady state unemployment in percent')
    c_e_bar ${\bar{e}}$ (long_name = 'Quarterly employment trend in percent')
    c_beta_bar ${\bar{\beta}}$ (long_name = 'Inverse discount factor in percent')
    c_psi_w ${\psi_{w}}$ (long_name = 'Steady state wage markup')
    c_l_k ${l_{k}}$ (long_name = 'Labour to capital ratio')
    c_w ${w}$ (long_name = 'Steady state real wage')
    c_1 ${c_{1}}$ (long_name = 'Forward consumption coefficient')
    c_2 ${c_{2}}$ (long_name = 'Consumption interest sensitivity')
    i_1 ${i_{1}}$ (long_name = 'Investment lag coefficient')
    i_2 ${i_{2}}$ (long_name = 'Investment value sensitivity')
    q_1 ${q_{1}}$ (long_name = 'Capital value rental weight')
    pi_1 ${\pi_{1}}$ (long_name = 'Forward inflation coefficient')
    pi_2 ${\pi_{2}}$ (long_name = 'Phillips curve slope')
    w_1 ${w_{1}}$ (long_name = 'Wage equation slope')
    k_1 ${k_{1}}$ (long_name = 'Capital stock persistence')
    k_2 ${k_{2}}$ (long_name = 'Capital adjustment coefficient')
    e_1 ${e_{1}}$ (long_name = 'Employment adjustment coefficient')
    c_rho_b ${\rho_{b}}$ (long_name = 'Risk premium persistence')
    c_rho_q ${\rho_{q}}$ (long_name = 'Investment efficiency persistence')
    c_rho_g ${\rho_{g}}$ (long_name = 'Government spending persistence')
    c_rho_a ${\rho_{a}}$ (long_name = 'Technology persistence')
    c_rho_g_a ${\rho_{ga}}$ (long_name = 'Technology loading in spending shock')
    c_rho_p ${\rho_{p}}$ (long_name = 'Price markup persistence')
    c_mu_p ${\mu_{p}}$ (long_name = 'Price markup moving average coefficient')
    c_rho_s ${\rho_{s}}$ (long_name = 'Labour supply persistence')
    c_rho_w ${\rho_{w}}$ (long_name = 'Wage markup persistence')
    c_mu_w ${\mu_{w}}$ (long_name = 'Wage markup moving average coefficient')
    c_rho_r ${\rho_{r}}$ (long_name = 'Monetary policy persistence')
    sigma_eta_a ${\sigma_{a}}$ (long_name = 'Technology innovation standard deviation')
    sigma_eta_b ${\sigma_{b}}$ (long_name = 'Risk premium innovation standard deviation')
    sigma_eta_g ${\sigma_{g}}$ (long_name = 'Government spending innovation standard deviation')
    sigma_eta_q ${\sigma_{q}}$ (long_name = 'Investment efficiency innovation standard deviation')
    sigma_eta_r ${\sigma_{r}}$ (long_name = 'Monetary policy innovation standard deviation')
    sigma_eta_p ${\sigma_{p}}$ (long_name = 'Price markup innovation standard deviation')
    sigma_eta_w ${\sigma_{w}}$ (long_name = 'Wage markup innovation standard deviation')
    sigma_eta_s ${\sigma_{s}}$ (long_name = 'Labour supply innovation standard deviation')
;

@#include CALIBRATION_FILE

model(linear);
[name = '01 Aggregate consumption']
c=c_1*c(+1)+(1-c_1)*c(-1)-c_2*(r-pi(+1)-epsilon_b);
[name = '02 Investment']
i=i_1*i(-1)+(1-i_1)*i(+1)+i_2*q+epsilon_q;
[name = '03 Value of installed capital']
q=-(r-pi(+1)-epsilon_b)+q_1*r_k(+1)+(1-q_1)*q(+1);
[name = '04 resource constraint']
y=c_c_y*c+c_i_y*i+c_v_y*v+epsilon_g;
[name = '05 production function']
y=c_psi_p*(c_alpha*k+(1-c_alpha)*n+epsilon_a);
[name = '06 Price Phillips curve']
pi-c_gamma_p*pi(-1)=pi_1*(pi(+1)-c_gamma_p*pi)-pi_2*(-mc+100*epsilon_p);
[name = '07 Real marginal cost']
mc=(1-c_alpha)*w+c_alpha*r_k-epsilon_a;
[name = '08 Wage setting equation']
w-w(-1)+pi=c_gamma_w*pi(-1)+c_beta*(w(+1)-w+pi(+1)-c_gamma_w*pi)-w_1*(c_omega*u-100*epsilon_w);
[name = '09 Inverse labour supply elasticity']
c_omega*u= w-(z+epsilon_s+c_omega*e);
[name = '10 Inverse labour supply elasticity']
c_omega*u_n=100*epsilon_w;
[name = '11 Labour force']
l=u+e;
[name = '12 Smoothed consumption trend']
z=(1-c_v)*z(-1)+c_v/(1-c_h/c_tau)*(c-c_h/c_tau*c(-1));
[name = '13 Installed capital stock']
k_bar=k_1*k_bar(-1)+(1-k_1)*i+k_2*epsilon_q;
[name = '14 Capital services']
k=v+k_bar(-1);
[name = '15 Capital utilization']
v=(1-c_psi)/c_psi*r_k;
[name = '16 Capital services']
k=w-r_k+n;
[name = '17 Quarterly nominal interest rate']
r=c_rho_intr*r(-1)+(1-c_rho_intr)*(c_r_pi*pi+c_r_y*y_gap+c_r_dy*(y_gap-y_gap(-1)))-epsilon_r;
[name = '18 Employment']
e-e(-1)=c_beta*(e(+1)-e)+e_1*(n-e);
[name = '19 Aggregate consumption under flexible prices']
c_f=c_1*c_f(+1)+(1-c_1)*c_f(-1)-c_2*(r_f-epsilon_b);
[name = '20 Investment under flexible prices']
inv_f=i_1*inv_f(-1)+(1-i_1)*inv_f(+1)+i_2*q_f+epsilon_q;
[name = '21 Value of installed capital under flexible prices']
q_f=-(r_f-epsilon_b)+q_1*r_k_f(+1)+(1-q_1)*q_f(+1);
[name = '22 Flexible economy resource constraint']
y_f=c_c_y*c_f+c_i_y*inv_f+c_v_y*v_f+epsilon_g;
[name = '23 Flexible economy production function']
y_f=c_psi_p*(c_alpha*k_f+(1-c_alpha)*n_f+epsilon_a);
[name = '24 0']
0=(1-c_alpha)*w_f+c_alpha*r_k_f-epsilon_a;
[name = '25 Real wage in domestic goods under flexible prices']
w_f=z_f+epsilon_s+c_omega*n_f;
[name = '26 Smoothed consumption trend under flexible prices']
z_f=(1-c_v)*z_f(-1)+c_v/(1-c_h/c_tau)*(c_f-c_h/c_tau*c_f(-1));
[name = '27 Installed capital stock under flexible prices']
k_bar_f=k_1*k_bar_f(-1)+(1-k_1)*inv_f+k_2*epsilon_q;
[name = '28 Capital services under flexible prices']
k_f=v_f+k_bar_f(-1);
[name = '29 Capital utilization under flexible prices']
v_f=(1-c_psi)/c_psi*r_k_f;
[name = '30 Capital services under flexible prices']
k_f=w_f-r_k_f+n_f;
[name = '31 Employment under flexible prices']
e_f-e_f(-1)=c_beta*(e_f(+1)-e_f)+e_1*(n_f-e_f);
[name = '32 Output gap']
y_gap=y-y_f;
[name = '33 Risk premium shock process']
epsilon_b=c_rho_b*epsilon_b(-1)+eta_b;
[name = '34 Investment efficiency shock process']
epsilon_q=c_rho_q*epsilon_q(-1)+eta_q;
[name = '35 Government spending shock process']
epsilon_g=c_rho_g*epsilon_g(-1)+eta_g+c_rho_g_a*eta_a;
[name = '36 Technology shock process']
epsilon_a=c_rho_a*epsilon_a(-1)+eta_a;
[name = '37 Price markup shock process']
epsilon_p=c_rho_p*epsilon_p(-1)+eta_p-c_mu_p*eta_p(-1);
[name = '38 Monetary policy shock process']
epsilon_r=c_rho_r*epsilon_r(-1)+eta_r;
[name = '39 Labour supply shock process']
epsilon_s=c_rho_s*epsilon_s(-1)+eta_s;
[name = '40 Wage markup shock process']
epsilon_w=c_rho_w*epsilon_w(-1)+eta_w-c_mu_w*eta_w(-1);
[name = '41 Annualized nominal interest rate']
r_year=4*r;
[name = '42 Four quarter consumption inflation']
pi_year=pi+pi(-1)+pi(-2)+pi(-3);
@#include MEASUREMENT_EQ_FILE
end;

varobs dy_obs dc_obs di_obs pi_obs dw_obs de_obs u_obs r_obs;

@#include SHOCKS_FILE

write_latex_original_model;
write_latex_static_model;
write_latex_dynamic_model;

steady;
check;
stoch_simul(periods = 1000, irf = 40);
