function pars = parameters(data) 


% %% load data 
% 
% t = data.t; 
% T = data.T;
% 
% AoPmin = data.AoPmin; 
% Flowmax = data.Flowmax; 

%%

% These are scaling factors that Hamid had in his code 
x = 3; 
y = 3*x; 

C_PA = 0.0013/x;  % mL / mmHg
L_PA = 2.0; % mmHg / (mL sec)
R_PA = 4; % mmHg / (mL / sec) ***
R_PV = 2; % mmHg / (mL / sec)
C_PV = 0.0254/x; % mL / mmHg

% This is a scaling factor that I implemented for the Hem data
z = 5; %1; 

Rm_0 = z*44; % mmHg / (mL / sec)
Ra_0 = 1.2*Rm_0;
Rv_0 = 0.5*Rm_0;

Va_0 = 2.5/9; % mL
Vv_0 = 8.0/9; % mL
Vc   = 0.01*Va_0; % mL

Ca_epi = 0.013/y; % mL / mmHg ***
Ca_mid = 0.013/y; % mL / mmHg ***
Ca_end = 0.013/y; % mL / mmHg ***
Cv     = 0.254/y; % mL / mmHg

gamma = 0.75; 

cf_epi = 0.55; % epi/endo compliance factor
rf_epi = 1.28; % epi/endo resistance factor
cf_mid = 0.68; % epi/mid compliance factor
rf_mid = 1.12; % epi/mid resistance factor

pars = [C_PA; L_PA; R_PA; R_PV; C_PV; 
    Rm_0; Ra_0; Rv_0; 
    Va_0; Vv_0; Vc; 
    Ca_epi; Ca_mid; Ca_end; Cv; 
    gamma; 
    cf_epi; rf_epi; cf_mid; rf_mid;
    ];
