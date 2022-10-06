function pars = parameters(data) 

scale = data.scale; 

%% Perfusion model parameters 

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

rf_epi = .75*2.23; % epi/endo resistance factor
rf_mid = .5*2.42; %epi/mid resistance factor

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


%% Representative vessel model parameters 

% Epicardial layer 
Cp_epi    = 1.05098446;
Ap_epi    = 120.38092108;
Bp_epi    = 1.90550636;
phi_p_epi = 20.73628316;
phi_m_epi = 175.43903226;
Cm_epi    = 107.65169583;
rho_m_epi = 272.89492167; 
C_myo_epi = 27.48287606; 
C_met_epi = 0.21975875; 
C_HR_epi  = 0.00288978; 
C0_epi    = -9.73513431; 
HR0_epi   = 99.99999999;
gD_epi    = 0.025; 
gA_epi    = gD_epi;

% Mid layer  
Cp_mid    = 1.55823335;
Ap_mid    = 82.35302166;
Bp_mid    = 11.68282319; 
phi_p_mid = 1.20888157; 
phi_m_mid = 133.57678380;
Cm_mid    = 68.60612021; 
rho_m_mid = 318.08196194; 
C_myo_mid = 13.92338467; 
C_met_mid = 0.08527874; 
C_HR_mid  = 0.01560819;
C0_mid    = -3.29582868;
HR0_mid   = 99.99999999;
gD_mid    = 0.05; 
gA_mid    = gD_mid; 

% Endocardial layer
Cp_end    = 11.87184929;  
Ap_end    = 81.11894037;  
Bp_end    = 1.89700187;  
phi_p_end = -8.57507696;  
phi_m_end = 50.86258266; 
Cm_end    = 199.55879151;
rho_m_end = 190.07671964;
C_myo_end = 10.64161129; 
C_met_end = 0.14024027;  
C_HR_end  = 0.10000000;  
C0_end    = -2.68959149; 
HR0_end   = 84.20208499; 
gD_end    = 0.075; 
gA_end    = gD_end; 


%% Outputs -  Perfusion model 

params_perf = [C_PA; L_PA; R_PA; R_PV; C_PV; 
    Rm_0; Ra_0; Rv_0; 
    Va_0; Vv_0; Vc; 
    Ca_epi; Ca_mid; Ca_end; Cv; 
    gamma; 
    rf_epi; rf_mid;
    ];

ub_perf = params_perf * 10; 
lb_perf = params_perf / 10; 

params_names_perf = {'C_{PA}','L_{PA}','R_{PA}','R_{PV}','C_{PV}',...
    'R_{m,0}','R_{a,0}','R_{v,0}', ...
    'V_{a,0}','V_{v,0}','V_{c}',...
    'C_{a,epi}','C_{a,mid}','C_{a,end}','C_v', ... 
    '\gamma','r_{f,epi}','r_{f,mid}', ...
    }; 

%% Outputs - Representative vessel model 

params_names_repvessel = {'C_p','A_p','B_p', ...
    '\phi_p','\phi_m',...
    'C_m','\rho_m',...
    'C_{myo}', 'C_{met}', 'C_{HR}', 'C_0', ... 
    'HR_0', ...
    }; 

% Epicardial layer
params_epi = [Cp_epi; Ap_epi; Bp_epi; 
    phi_p_epi; phi_m_epi; 
    Cm_epi; rho_m_epi; 
    C_myo_epi; C_met_epi; C_HR_epi; C0_epi; 
    HR0_epi; 
    gD_epi; gA_epi; 
    ]; 

ub_epi = params_epi * 10; 
lb_epi = params_epi / 10; 

% Mid layer
params_mid = [Cp_mid; Ap_mid; Bp_mid; 
    phi_p_mid; phi_m_mid; 
    Cm_mid; rho_m_mid; 
    C_myo_mid; C_met_mid; C_HR_mid; C0_mid; 
    HR0_mid; 
    gD_mid; gA_mid; 
    ]; 

ub_mid = params_mid * 10; 
lb_mid = params_mid / 10; 

% Endocardial layer
params_end = [Cp_end; Ap_end; Bp_end; 
    phi_p_end; phi_m_end; 
    Cm_end; rho_m_end 
    C_myo_end; C_met_end; C_HR_end; C0_end; 
    HR0_end; 
    gD_end; gA_end; 
    ]; 

ub_end = params_end * 10; 
lb_end = params_end / 10; 

%% Parameter structure  

pars.perfusion.params       = log(params_perf); 
pars.perfusion.ub           = log(ub_perf); 
pars.perfusion.lb           = log(lb_perf);
pars.perfusion.params_names = params_names_perf; 

pars.repvessel.epi.params       = params_epi; 
pars.repvessel.epi.ub           = ub_epi; 
pars.repvessel.epi.lb           = lb_epi; 
pars.repvessel.epi.params_names = params_names_repvessel; 

pars.repvessel.mid.params       = params_mid; 
pars.repvessel.mid.ub           = ub_mid; 
pars.repvessel.mid.lb           = lb_mid; 
pars.repvessel.mid.params_names = params_names_repvessel; 

pars.repvessel.end.params       = params_end; 
pars.repvessel.end.ub           = ub_end; 
pars.repvessel.end.lb           = lb_end; 
pars.repvessel.end.params_names = params_names_repvessel; 
