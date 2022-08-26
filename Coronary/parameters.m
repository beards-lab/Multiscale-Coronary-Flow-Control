function pars = parameters(scalepars,data) 

LVweight = data.LVweight; 

%% Scaling parameters 

a = scalepars(1); 
b = scalepars(2); 
c = scalepars(3); 
d = scalepars(4); 
e = scalepars(5); 

%% Parameters 

scale = 1 / LVweight; 

C_PA = 0.0013/a * scale;  % mL / mmHg / 100 g
L_PA = 2.0; % mmHg / (mL sec)
R_PA = 6 * a / scale ; % mmHg / (mL / sec)
R_PV = 1 / scale; % mmHg / (mL / sec)
C_PV = 0.0254 * scale; % mL / mmHg / 100 g

Rm_0 = c * 44 / scale; % mmHg / (mL / sec)
Ra_0 = 1.2*Rm_0;
Rv_0 = 0.5*Rm_0;

Ca_epi = 0.013/b * scale; % mL / mmHg ***
Ca_mid = 0.013/b * scale; % mL / mmHg ***
Ca_end = 0.013/b * scale; % mL / mmHg ***
Cv     = 0.254   * scale; % mL / mmHg

Va_0 = 2.5/b * scale; % mL
Vv_0 = 8.0 * scale; % mL
Vc   = 0.01*Va_0 ; % mL

gamma = 0.75; 

cf_epi = 0.55 / d; % epi/endo compliance factor
rf_epi = 1.28 * d *2; % epi/endo resistance factor
cf_mid = 0.68 / e; % epi/mid compliance factor
rf_mid = 1.12 * e; % epi/mid resistance factor

pars = [C_PA; L_PA; R_PA; R_PV; C_PV; 
    Rm_0; Ra_0; Rv_0; 
    Va_0; Vv_0; Vc; 
    Ca_epi; Ca_mid; Ca_end; Cv; 
    gamma; 
    cf_epi; rf_epi; cf_mid; rf_mid;
    ];
