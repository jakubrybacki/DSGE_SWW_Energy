// SWW energy model. Calibration source: ../Calibrations.xlsx.
// Generate inputs: python calibration/generate_mod_inputs.py --country EA20
@#ifndef RUN_ESTIMATION
@#define RUN_ESTIMATION = 0
@#endif
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
    rk ${\mathrm{rk}}$ (long_name = 'Rental rate of capital')
    y ${\mathrm{y}}$ (long_name = 'Gross domestic output')
    v ${\mathrm{v}}$ (long_name = 'Capital utilization')
    k ${\mathrm{k}}$ (long_name = 'Capital services')
    n ${\mathrm{n}}$ (long_name = 'Hours worked')
    mc ${\mathrm{mc}}$ (long_name = 'Real marginal cost')
    w ${\mathrm{w}}$ (long_name = 'Real wage in domestic goods')
    wc ${\mathrm{wc}}$ (long_name = 'Real wage in consumption goods')
    z ${\mathrm{z}}$ (long_name = 'Smoothed consumption trend')
    u ${\mathrm{u}}$ (long_name = 'Unemployment rate deviation')
    e ${\mathrm{e}}$ (long_name = 'Employment')
    un ${\mathrm{un}}$ (long_name = 'Natural unemployment')
    l ${\mathrm{l}}$ (long_name = 'Labour force')
    kbar ${\bar{k}}$ (long_name = 'Installed capital stock')
    ygap ${\mathrm{ygap}}$ (long_name = 'Output gap')
    cn ${\mathrm{cn}}$ (long_name = 'Nonenergy consumption')
    ce ${\mathrm{ce}}$ (long_name = 'Household energy consumption')
    en ${\mathrm{en}}$ (long_name = 'Firm energy input')
    etot ${\mathrm{etot}}$ (long_name = 'Total energy imports')
    exports ${\mathrm{exports}}$ (long_name = 'Exports financing energy imports')
    pc ${\mathrm{pc}}$ (long_name = 'Relative consumption price')
    piC ${\pi^{C}}$ (long_name = 'Consumption inflation')
    piE ${\pi^{E}}$ (long_name = 'Energy inflation')
    pE ${p^{E}}$ (long_name = 'Relative energy price')
    gdp ${\mathrm{gdp}}$ (long_name = 'Real gross domestic product')
    cf ${\mathrm{cf}}$ (long_name = 'Aggregate consumption under flexible prices')
    rf ${\mathrm{rf}}$ (long_name = 'Real consumption interest rate under flexible prices')
    invf ${\mathrm{invf}}$ (long_name = 'Investment under flexible prices')
    qf ${\mathrm{qf}}$ (long_name = 'Value of installed capital under flexible prices')
    rkf ${\mathrm{rkf}}$ (long_name = 'Rental rate of capital under flexible prices')
    vf ${\mathrm{vf}}$ (long_name = 'Capital utilization under flexible prices')
    kf ${\mathrm{kf}}$ (long_name = 'Capital services under flexible prices')
    nf ${\mathrm{nf}}$ (long_name = 'Hours worked under flexible prices')
    wf ${\mathrm{wf}}$ (long_name = 'Real wage in domestic goods under flexible prices')
    zf ${\mathrm{zf}}$ (long_name = 'Smoothed consumption trend under flexible prices')
    ef ${\mathrm{ef}}$ (long_name = 'Employment under flexible prices')
    kbarf ${\mathrm{kbarf}}$ (long_name = 'Installed capital stock under flexible prices')
    yf ${\mathrm{yf}}$ (long_name = 'Gross domestic output under flexible prices')
    cnf ${\mathrm{cnf}}$ (long_name = 'Nonenergy consumption under flexible prices')
    cef ${\mathrm{cef}}$ (long_name = 'Household energy consumption under flexible prices')
    enf ${\mathrm{enf}}$ (long_name = 'Firm energy input under flexible prices')
    etotf ${\mathrm{etotf}}$ (long_name = 'Total energy imports under flexible prices')
    exportsf ${\mathrm{exportsf}}$ (long_name = 'Exports financing energy imports under flexible prices')
    gdpf ${\mathrm{gdpf}}$ (long_name = 'Real gross domestic product under flexible prices')
    epsilonb ${\epsilon_{b}}$ (long_name = 'Risk premium shock process')
    epsilonq ${\epsilon_{q}}$ (long_name = 'Investment efficiency shock process')
    epsilong ${\epsilon_{g}}$ (long_name = 'Government spending shock process')
    epsilona ${\epsilon_{a}}$ (long_name = 'Technology shock process')
    epsilonp ${\epsilon_{p}}$ (long_name = 'Price markup shock process')
    epsilons ${\epsilon_{s}}$ (long_name = 'Labour supply shock process')
    epsilonw ${\epsilon_{w}}$ (long_name = 'Wage markup shock process')
    epsilonr ${\epsilon_{r}}$ (long_name = 'Monetary policy shock process')
    dyobs ${\mathrm{dy}^{obs}}$ (long_name = 'Observed quarterly GDP growth')
    dcobs ${\mathrm{dc}^{obs}}$ (long_name = 'Observed quarterly consumption growth')
    diobs ${\mathrm{di}^{obs}}$ (long_name = 'Observed quarterly investment growth')
    piobs ${\mathrm{pi}^{obs}}$ (long_name = 'Observed quarterly inflation')
    dwobs ${\mathrm{dw}^{obs}}$ (long_name = 'Observed wage measurement series')
    deobs ${\mathrm{de}^{obs}}$ (long_name = 'Observed quarterly employment growth')
    uobs ${\mathrm{u}^{obs}}$ (long_name = 'Observed unemployment rate')
    robs ${\mathrm{r}^{obs}}$ (long_name = 'Observed annual nominal interest rate')
    pEobs ${\mathrm{pE}^{obs}}$ (long_name = 'Observed demeaned relative energy price')
    piDobs ${\mathrm{piD}^{obs}}$ (long_name = 'Diagnostic domestic inflation')
    piEobs ${\mathrm{piE}^{obs}}$ (long_name = 'Diagnostic energy inflation')
    ryear ${\mathrm{ryear}}$ (long_name = 'Annualized nominal interest rate')
    piyear ${\mathrm{piyear}}$ (long_name = 'Four quarter consumption inflation')
    piDyear ${\mathrm{piDyear}}$ (long_name = 'Four quarter domestic inflation')
;

varexo
    etab ${\eta_{b}}$ (long_name = 'Risk premium innovation')
    etaq ${\eta_{q}}$ (long_name = 'Investment efficiency innovation')
    etag ${\eta_{g}}$ (long_name = 'Government spending innovation')
    etaa ${\eta_{a}}$ (long_name = 'Technology innovation')
    etap ${\eta_{p}}$ (long_name = 'Price markup innovation')
    etas ${\eta_{s}}$ (long_name = 'Labour supply innovation')
    etaw ${\eta_{w}}$ (long_name = 'Wage markup innovation')
    etar ${\eta_{r}}$ (long_name = 'Monetary policy innovation')
    etaE ${\eta_{E}}$ (long_name = 'Relative energy price innovation')
;

parameters
    ch ${\mathrm{ch}}$ (long_name = 'External consumption habit')
    ctau ${\mathrm{ctau}}$ (long_name = 'Gross trend growth')
    cbeta ${\beta}$ (long_name = 'Discount factor')
    cphi ${\mathrm{cphi}}$ (long_name = 'Investment adjustment cost curvature')
    cdelta ${\delta}$ (long_name = 'Capital depreciation rate')
    cpsip ${\mathrm{cpsip}}$ (long_name = 'Price markup and fixed cost factor')
    calpha ${\alpha}$ (long_name = 'Capital production elasticity')
    cgammap ${\gamma_{p}}$ (long_name = 'Price indexation')
    cthetap ${\theta_{p}}$ (long_name = 'Calvo price rigidity')
    cepsp ${\mathrm{cepsp}}$ (long_name = 'Price aggregator curvature')
    cgammaw ${\gamma_{w}}$ (long_name = 'Wage indexation')
    cthetaw ${\theta_{w}}$ (long_name = 'Calvo wage rigidity')
    cepsw ${\mathrm{cepsw}}$ (long_name = 'Wage aggregator curvature')
    comega ${\mathrm{comega}}$ (long_name = 'Inverse labour supply elasticity')
    cv ${\mathrm{cv}}$ (long_name = 'Consumption trend adjustment')
    cpsi ${\mathrm{cpsi}}$ (long_name = 'Capital utilization cost parameter')
    crhointr ${\mathrm{crhointr}}$ (long_name = 'Interest rate smoothing')
    crpi ${\mathrm{crpi}}$ (long_name = 'Inflation response in policy rule')
    cry ${\mathrm{cry}}$ (long_name = 'Output gap response in policy rule')
    crdy ${\mathrm{crdy}}$ (long_name = 'Output gap growth response')
    cthetae ${\mathrm{cthetae}}$ (long_name = 'Employment adjustment rigidity')
    crk ${\mathrm{crk}}$ (long_name = 'Steady state capital rental rate')
    ccy ${\mathrm{ccy}}$ (long_name = 'Consumption to output ratio')
    ciy ${\mathrm{ciy}}$ (long_name = 'Investment to output ratio')
    cvy ${\mathrm{cvy}}$ (long_name = 'Utilization cost coefficient')
    cgy ${\mathrm{cgy}}$ (long_name = 'Government expenditure to output ratio')
    cky ${\mathrm{cky}}$ (long_name = 'Capital to output ratio')
    ctaubar ${\mathrm{ctaubar}}$ (long_name = 'Quarterly productivity trend in percent')
    cpi ${\mathrm{cpi}}$ (long_name = 'Gross steady state inflation')
    cpibar ${\mathrm{cpibar}}$ (long_name = 'Quarterly trend inflation in percent')
    crbar ${\mathrm{crbar}}$ (long_name = 'Quarterly steady state nominal rate')
    cubar ${\mathrm{cubar}}$ (long_name = 'Steady state unemployment in percent')
    cebar ${\mathrm{cebar}}$ (long_name = 'Quarterly employment trend in percent')
    cbetabar ${\mathrm{cbetabar}}$ (long_name = 'Inverse discount factor in percent')
    cpsiw ${\mathrm{cpsiw}}$ (long_name = 'Steady state wage markup')
    clk ${\mathrm{clk}}$ (long_name = 'Labour to capital ratio')
    cw ${\mathrm{cw}}$ (long_name = 'Steady state real wage')
    c1 ${\mathrm{c1}}$ (long_name = 'Forward consumption coefficient')
    c2 ${\mathrm{c2}}$ (long_name = 'Consumption interest sensitivity')
    i1 ${\mathrm{i1}}$ (long_name = 'Investment lag coefficient')
    i2 ${\mathrm{i2}}$ (long_name = 'Investment value sensitivity')
    q1 ${\mathrm{q1}}$ (long_name = 'Capital value rental weight')
    pi1 ${\mathrm{pi1}}$ (long_name = 'Forward inflation coefficient')
    pi2 ${\mathrm{pi2}}$ (long_name = 'Phillips curve slope')
    w1 ${\mathrm{w1}}$ (long_name = 'Wage equation slope')
    k1 ${\mathrm{k1}}$ (long_name = 'Capital stock persistence')
    k2 ${\mathrm{k2}}$ (long_name = 'Capital adjustment coefficient')
    e1 ${\mathrm{e1}}$ (long_name = 'Employment adjustment coefficient')
    crhob ${\mathrm{crhob}}$ (long_name = 'Risk premium persistence')
    crhoq ${\mathrm{crhoq}}$ (long_name = 'Investment efficiency persistence')
    crhog ${\mathrm{crhog}}$ (long_name = 'Government spending persistence')
    crhoa ${\mathrm{crhoa}}$ (long_name = 'Technology persistence')
    crhoga ${\mathrm{crhoga}}$ (long_name = 'Technology loading in spending shock')
    crhop ${\mathrm{crhop}}$ (long_name = 'Price markup persistence')
    cmup ${\mathrm{cmup}}$ (long_name = 'Price markup moving average coefficient')
    crhos ${\mathrm{crhos}}$ (long_name = 'Labour supply persistence')
    crhow ${\mathrm{crhow}}$ (long_name = 'Wage markup persistence')
    cmuw ${\mathrm{cmuw}}$ (long_name = 'Wage markup moving average coefficient')
    crhor ${\mathrm{crhor}}$ (long_name = 'Monetary policy persistence')
    cnu ${\nu}$ (long_name = 'Energy production elasticity')
    comegaE ${\omega_{E}}$ (long_name = 'Energy consumption budget share')
    crhoE ${\mathrm{crhoE}}$ (long_name = 'Relative energy price persistence')
    csigmaE ${\mathrm{csigmaE}}$ (long_name = 'Energy innovation standard deviation')
    cshareN ${\mathrm{cshareN}}$ (long_name = 'Nonenergy consumption to gross output')
    cshareEn ${\mathrm{cshareEn}}$ (long_name = 'Firm energy expenditure to gross output')
    cshareCe ${\mathrm{cshareCe}}$ (long_name = 'Household energy expenditure to output')
    cshareX ${\mathrm{cshareX}}$ (long_name = 'Exports to gross output')
    cweightEn ${\mathrm{cweightEn}}$ (long_name = 'Firm weight in total energy imports')
    cweightCe ${\mathrm{cweightCe}}$ (long_name = 'Household weight in total energy imports')
    cshareGDP ${\mathrm{cshareGDP}}$ (long_name = 'GDP to gross output ratio')
    calphaN ${\mathrm{calphaN}}$ (long_name = 'Labour production elasticity')
    cgovGDP ${\mathrm{cgovGDP}}$ (long_name = 'Government expenditure to GDP ratio')
    sigma_etaa ${\sigma_{a}}$ (long_name = 'Technology innovation standard deviation')
    sigma_etab ${\sigma_{b}}$ (long_name = 'Risk premium innovation standard deviation')
    sigma_etag ${\sigma_{g}}$ (long_name = 'Government spending innovation standard deviation')
    sigma_etaq ${\sigma_{q}}$ (long_name = 'Investment efficiency innovation standard deviation')
    sigma_etar ${\sigma_{r}}$ (long_name = 'Monetary policy innovation standard deviation')
    sigma_etap ${\sigma_{p}}$ (long_name = 'Price markup innovation standard deviation')
    sigma_etaw ${\sigma_{w}}$ (long_name = 'Wage markup innovation standard deviation')
    sigma_etas ${\sigma_{s}}$ (long_name = 'Labour supply innovation standard deviation')
;

@#include CALIBRATION_FILE

model(linear);
[name = '01 Relative consumption price']
pc=comegaE*pE;
[name = '02 Consumption inflation']
piC=pi+pc-pc(-1);
[name = '03 Energy inflation']
piE=pi+pE-pE(-1);
[name = '04 Real wage in consumption goods']
wc=w-pc;
[name = '05 Nonenergy consumption']
cn=c+pc;
[name = '06 Household energy consumption']
ce=c+pc-pE;
[name = '07 Aggregate consumption']
c=c1*c(+1)+(1-c1)*c(-1)-c2*(r-piC(+1)-epsilonb);
[name = '08 Investment']
i=i1*i(-1)+(1-i1)*i(+1)+i2*q+epsilonq;
[name = '09 Value of installed capital']
q=-(r-pi(+1)-epsilonb)+q1*rk(+1)+(1-q1)*q(+1);
[name = '10 Total energy imports']
etot=cweightEn*en+cweightCe*ce;
[name = '11 Exports financing energy imports']
exports=pE+etot;
[name = '12 resource constraint']
y=cshareN*cn+ciy*i+cvy*v+epsilong+cshareX*exports;
[name = '13 production function']
y=cpsip*(calpha*k+calphaN*n+cnu*en+epsilona);
[name = '14 Real marginal cost']
mc=calphaN*w+calpha*rk+cnu*pE-epsilona;
[name = '15 Firm energy input']
en=mc+y/cpsip-pE;
[name = '16 Capital services']
k=w-rk+n;
[name = '17 Price Phillips curve']
pi-cgammap*pi(-1)=pi1*(pi(+1)-cgammap*pi)-pi2*(-mc+100*epsilonp);
[name = '18 Wage setting equation']
wc-wc(-1)+piC=cgammaw*piC(-1)+cbeta*(wc(+1)-wc+piC(+1)-cgammaw*piC) -w1*(comega*u-100*epsilonw);
[name = '19 Inverse labour supply elasticity']
comega*u=wc-(z+epsilons+comega*e);
[name = '20 Inverse labour supply elasticity']
comega*un=100*epsilonw;
[name = '21 Labour force']
l=u+e;
[name = '22 Smoothed consumption trend']
z=(1-cv)*z(-1)+cv/(1-ch/ctau)*(c-ch/ctau*c(-1));
[name = '23 Installed capital stock']
kbar=k1*kbar(-1)+(1-k1)*i+k2*epsilonq;
[name = '24 Capital services']
k=v+kbar(-1);
[name = '25 Capital utilization']
v=(1-cpsi)/cpsi*rk;
[name = '26 Quarterly nominal interest rate']
r=crhointr*r(-1)+(1-crhointr)*(crpi*piC+cry*ygap+crdy*(ygap-ygap(-1)))-epsilonr;
[name = '27 Employment']
e-e(-1)=cbeta*(e(+1)-e)+e1*(n-e);
[name = '28 Real gross domestic product']
gdp=(y-cshareEn*en)/cshareGDP;
[name = '29 Nonenergy consumption under flexible prices']
cnf=cf+pc;
[name = '30 Household energy consumption under flexible prices']
cef=cf+pc-pE;
[name = '31 Aggregate consumption under flexible prices']
cf=c1*cf(+1)+(1-c1)*cf(-1)-c2*(rf-epsilonb);
[name = '32 Investment under flexible prices']
invf=i1*invf(-1)+(1-i1)*invf(+1)+i2*qf+epsilonq;
[name = '33 Value of installed capital under flexible prices']
qf=-(rf+pc(+1)-pc-epsilonb)+q1*rkf(+1)+(1-q1)*qf(+1);
[name = '34 Total energy imports under flexible prices']
etotf=cweightEn*enf+cweightCe*cef;
[name = '35 Exports financing energy imports under flexible prices']
exportsf=pE+etotf;
[name = '36 Flexible economy resource constraint']
yf=cshareN*cnf+ciy*invf+cvy*vf+epsilong+cshareX*exportsf;
[name = '37 Flexible economy production function']
yf=cpsip*(calpha*kf+calphaN*nf+cnu*enf+epsilona);
[name = '38 0']
0=calphaN*wf+calpha*rkf+cnu*pE-epsilona;
[name = '39 Firm energy input under flexible prices']
enf=yf/cpsip-pE;
[name = '40 Real wage in domestic goods under flexible prices']
wf=pc+zf+epsilons+comega*nf;
[name = '41 Smoothed consumption trend under flexible prices']
zf=(1-cv)*zf(-1)+cv/(1-ch/ctau)*(cf-ch/ctau*cf(-1));
[name = '42 Installed capital stock under flexible prices']
kbarf=k1*kbarf(-1)+(1-k1)*invf+k2*epsilonq;
[name = '43 Capital services under flexible prices']
kf=vf+kbarf(-1);
[name = '44 Capital utilization under flexible prices']
vf=(1-cpsi)/cpsi*rkf;
[name = '45 Capital services under flexible prices']
kf=wf-rkf+nf;
[name = '46 Employment under flexible prices']
ef-ef(-1)=cbeta*(ef(+1)-ef)+e1*(nf-ef);
[name = '47 Real gross domestic product under flexible prices']
gdpf=(yf-cshareEn*enf)/cshareGDP;
[name = '48 Output gap']
ygap=gdp-gdpf;
[name = '49 Relative energy price']
pE=crhoE*pE(-1)+etaE;
[name = '50 Risk premium shock process']
epsilonb=crhob*epsilonb(-1)+etab;
[name = '51 Investment efficiency shock process']
epsilonq=crhoq*epsilonq(-1)+etaq;
[name = '52 Government spending shock process']
epsilong=crhog*epsilong(-1)+etag+crhoga*etaa;
[name = '53 Technology shock process']
epsilona=crhoa*epsilona(-1)+etaa;
[name = '54 Price markup shock process']
epsilonp=crhop*epsilonp(-1)+etap-cmup*etap(-1);
[name = '55 Monetary policy shock process']
epsilonr=crhor*epsilonr(-1)+etar;
[name = '56 Labour supply shock process']
epsilons=crhos*epsilons(-1)+etas;
[name = '57 Wage markup shock process']
epsilonw=crhow*epsilonw(-1)+etaw-cmuw*etaw(-1);
[name = '58 Annualized nominal interest rate']
ryear=4*r;
[name = '59 Four quarter consumption inflation']
piyear=piC+piC(-1)+piC(-2)+piC(-3);
[name = '60 Four quarter domestic inflation']
piDyear=pi+pi(-1)+pi(-2)+pi(-3);
@#include MEASUREMENT_EQ_FILE
end;

varobs dyobs dcobs diobs piobs dwobs deobs uobs robs pEobs;

@#include SHOCKS_FILE

write_latex_original_model;
write_latex_static_model;
write_latex_dynamic_model;

steady;
check;
model_diagnostics;
@#if RUN_ESTIMATION == 0
stoch_simul(order=1,irf=40,irf_shocks=(etaE),nograph,noprint);
@#else
// First conditional maximum-likelihood fit: no priors, beta and core fixed.
// Estimate innovations directly; sigma_* parameters only initialize stderr.
estimated_params;
 stderr etaa, sigma_etaa, 0.00001, 100;
 stderr etab, sigma_etab, 0.00001, 100;
 stderr etag, sigma_etag, 0.00001, 100;
 stderr etaq, sigma_etaq, 0.00001, 100;
 stderr etar, sigma_etar, 0.00001, 100;
 stderr etap, sigma_etap, 0.00001, 100;
 stderr etaw, sigma_etaw, 0.00001, 100;
 stderr etas, sigma_etas, 0.00001, 100;
 stderr etaE, csigmaE, 0.00001, 100;
 crhoE, , 0.001, 0.995;
 cnu, , 0, 0.20;
 comegaE, , 0.001, 0.35;
end;
estimated_params_init(use_calibration);
end;
@#define DATA_FILE = "data/" + COUNTRY + "/dane.mat"
estimation(datafile='@{DATA_FILE}',order=1,mode_compute=0,mh_replic=0,
  lik_init=1,kalman_algo=1,cova_compute=0,nograph,nodisplay,
  optim=('MaxIter',1000,'TolFun',1e-8));
@#endif




