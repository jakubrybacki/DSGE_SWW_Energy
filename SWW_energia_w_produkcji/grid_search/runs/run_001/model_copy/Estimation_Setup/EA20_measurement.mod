// Common measurement equations for simulation and estimation.
// robs is annual percent in the data. robs/4 is quarterly percent, like crbar and r.
// Intercepts retain the workbook calibration; sample means below are diagnostics.
// Data sample: 2009Q1 -- 2025Q4
// Sample mean dyobs: 0.266129780311975
// Sample mean dcobs: 0.213158659844676
// Sample mean diobs: 0.226554596144201
// Sample mean piobs: 0.510556853356593
// Sample mean dwobs: 0.608506745899754
// Sample mean deobs: 0.155296293489155
// Sample mean uobs: 9.03970588235294
// Sample mean robs: 0.936430189411327
// Sample mean pEobs: -2.44708256925881e-15
// Source SHA256: 6b3d0f50bdd6ee331d650dfc8fd184a06d320d4c938db875196a3c59f8f26e57
[name = 'Observed quarterly GDP growth']
dyobs=ctaubar+cebar+gdp-gdp(-1);
[name = 'Observed quarterly consumption growth']
dcobs=ctaubar+cebar+c-c(-1);
[name = 'Observed quarterly investment growth']
diobs=ctaubar+cebar+i-i(-1);
[name = 'Observed quarterly inflation']
piobs=cpibar+piC;
[name = 'Observed wage measurement series']
dwobs=ctaubar+w-w(-1)+cpibar+pi;
[name = 'Observed quarterly employment growth']
deobs=cebar+e-e(-1);
[name = 'Observed unemployment rate']
uobs=cubar+u;
[name = 'Observed annual nominal interest rate']
robs/4=crbar+r;
[name = 'Observed demeaned relative energy price']
pEobs=pE;
[name = 'Diagnostic domestic inflation']
piDobs=cpibar+pi;
[name = 'Diagnostic energy inflation']
piEobs=cpibar+piE;
