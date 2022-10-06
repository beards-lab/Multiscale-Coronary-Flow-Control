function [pars,ub,lb,data] = parameters(data) 

scale = data.scale; 

%% Parameters 

% These values correspond to scalars that were already in Hamid's original
% code. 
a = .1; %.2; 
b = 1; %2;

C_PA = a * 0.0013 * scale;  % mL / mmHg / 100 g
L_PA = 2; % mmHg / (mL sec)
R_PA = 1 / scale; % * a / scale ; % mmHg / (mL / sec)
R_PV = 1 / scale; % mmHg / (mL / sec)
C_PV = 0.0254 * scale; % mL / mmHg / 100 g

% Rm_0 = 44 / scale; % mmHg / (mL / sec)
% Ra_0 = 1.2*Rm_0;
% Rv_0 = 0.5*Rm_0;

Ca_epi = b * 0.013 * scale; % mL / mmHg ***
Ca_mid = b * 0.013 * scale; % mL / mmHg ***
Ca_end = b * 0.013 * scale; % mL / mmHg ***
Cv     = 0.254   * scale; % mL / mmHg

Va_0 = 2.5 * scale; % mL
Vv_0 = 8.0 * scale; % mL
Vc   = 0.01 * Va_0 ; % mL

gamma = 0.75; 

rf_epi = 2.23; % epi/endo resistance factor
rf_mid = 2.42; %epi/mid resistance factor

%% A priori calculations 

P_Ao_M = data.P_Ao_M; 
% P_Ao_m = data.P_Ao_m; 
Q_myo_M = data.Q_myo_M; 
% P_LV_m = data.P_LV_m; 

P_Ao_dicr = .95 * P_Ao_M; % pressure at the dicrotic notch approximately 95% of systolic pressure 
P_PA_M = P_Ao_dicr - Q_myo_M * R_PA; 
 
Pa_epi_m = (50  / 120) * P_Ao_dicr; 
Pa_mid_m = (85  / 120) * P_Ao_dicr;  
Pa_end_m = (115 / 120) * P_Ao_dicr; 

% Pim_epi_m = 1.2 * (1/6) * P_LV_m; 
% Pim_mid_m = 1.2 * (1/2) * P_LV_m; 
% Pim_end_m = 1.2 * (5/6) * P_LV_m; 

% Va_epi_m = max( (Pa_epi_m - Pim_epi_m) * Ca_epi + Va_0, Vc); 
% Va_mid_m = max( (Pa_mid_m - Pim_mid_m) * Ca_mid + Va_0, Vc); 
% Va_end_m = max( (Pa_end_m - Pim_end_m) * Ca_end + Va_0, Vc); 

Ra_0 = (1/scale) * (1 / Q_myo_M) * ( ... 
    (P_PA_M - Pa_epi_m) + ... % Assume Ra_epi = Ra_mid = Ra_end = 1 for a priori calculations 
    (P_PA_M - Pa_mid_m) + ...
    (P_PA_M - Pa_end_m)); 

Rm_0 = Ra_0 / 1.2; 
Rv_0 = Rm_0 * .5; 
% 
% rf_epi = 1.25 * ... 
%     (P_PA_M - Pa_epi_m) / (P_PA_M - Pa_end_m) * ... 
%     (Va_epi_m / Va_end_m )^2; 
% rf_mid = 1.25 * ... 
%     (P_PA_M - Pa_mid_m) / (P_PA_M - Pa_end_m) * ... 
%     (Va_mid_m / Va_end_m )^2; 

%% Outputs 

pars = [C_PA; L_PA; R_PA; R_PV; C_PV; 
    Rm_0; Ra_0; Rv_0; 
    Va_0; Vv_0; Vc; 
    Ca_epi; Ca_mid; Ca_end; Cv; 
    gamma; 
    rf_epi; rf_mid;
    ];

ub = pars * 10; 
lb = pars / 10; 

pars = log(pars); 
ub   = log(ub); 
lb   = log(lb); 

pars_names = {'C_{PA}','L_{PA}','R_{PA}','R_{PV}','C_{PV}',...
    'R_{m,0}','R_{a,0}','R_{v,0}', ...
    'V_{a,0}','V_{v,0}','V_{c}',...
    'C_{a,epi}','C_{a,mid}','C_{a,end}','C_v', ... 
    '\gamma','r_{f,epi}','r_{f,mid}'}; 
data.pars_names = pars_names; 
