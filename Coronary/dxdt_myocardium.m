function [dxdt, outputs] = dxdt_myocardium(t,x,pars,data,flag)

%% Data input 

% Pressure splines
AoP    = data.AoPspl(t); 
PLV    = data.PLVspl(t); 
dPLVdt = data.dPLVdtspl(t);

% Intramyocardial pressure (mmHg)
Pim_epi = 1.2 * (1/6) * PLV; 
Pim_mid = 1.2 * (1/2) * PLV; 
Pim_end = 1.2 * (5/6) * PLV;

% Derivative of intramyocardial pressure (mmHg s^{-1))
dPim_epidt = 1.2 * (1/6) * dPLVdt; 
dPim_middt = 1.2 * (1/2) * dPLVdt; 
dPim_enddt = 1.2 * (5/6) * dPLVdt; 

% Right atrial pressure (mmHg)
P_RA = 0; 

%% Parameters 

C_PA   = pars(1); 
L_PA   = pars(2); 
R_PA   = pars(3); 
R_PV   = pars(4); 
C_PV   = pars(5); 
Rm_0   = pars(6); 
Ra_0   = pars(7); 
Rv_0   = pars(8); 
Va_0   = pars(9); 
Vv_0   = pars(10); 
Vc     = pars(11); 
Ca_epi = pars(12); 
Ca_mid = pars(13); 
Ca_end = pars(14); 
Cv     = pars(15); 
gamma  = pars(16); 
cf_epi = pars(17); 
rf_epi = pars(18);
cf_mid = pars(19); 
rf_mid = pars(20); 

%% State variables 

P_PA   = x(1); 
Q_PA   = x(2); 
Pa_epi = x(3); 
Pa_mid = x(4);
Pa_end = x(5); 
Pv_epi = x(6); 
Pv_mid = x(7); 
Pv_end = x(8); 
P_PV   = x(9); 

%% Auxiliary equations 

Va_epi = max( cf_epi*( (Pa_epi - Pim_epi) * Ca_epi + Va_0), Vc); 
Va_mid = max( cf_mid*( (Pa_mid - Pim_mid) * Ca_mid + Va_0), Vc); 
Va_end = max(        ( (Pa_end - Pim_end) * Ca_end + Va_0), Vc); 

Vv_epi = cf_epi * ((Pv_epi - Pim_epi) * Cv + Vv_0); 
Vv_mid = cf_mid * ((Pv_mid - Pim_mid) * Cv + Vv_0); 
Vv_end =          ((Pv_end - Pim_end) * Cv + Vv_0); 

Ra_epi = rf_epi * Ra_0 * (Va_0 / Va_epi).^2; 
Ra_mid = rf_mid * Ra_0 * (Va_0 / Va_mid).^2; 
Ra_end =          Ra_0 * (Va_0 / Va_end).^2; 

Rv_epi = rf_epi * Rv_0 * (Vv_0 / Vv_epi).^2; 
Rv_mid = rf_mid * Rv_0 * (Vv_0 / Vv_mid).^2; 
Rv_end =          Rv_0 * (Vv_0 / Vv_end).^2; 

Rm_epi = Rm_0 * (gamma * (Ra_epi / Ra_0) + (1 - gamma) * (Rv_epi / Rv_0)); 
Rm_mid = Rm_0 * (gamma * (Ra_mid / Ra_0) + (1 - gamma) * (Rv_mid / Rv_0)); 
Rm_end = Rm_0 * (gamma * (Ra_end / Ra_0) + (1 - gamma) * (Rv_end / Rv_0)); 

Qa_epi = (P_PA - Pa_epi) / Ra_epi; 
Qa_mid = (P_PA - Pa_mid) / Ra_mid; 
Qa_end = (P_PA - Pa_end) / Ra_end; 

Qm_epi = (Pa_epi - Pv_epi) / Rm_epi; 
Qm_mid = (Pa_mid - Pv_mid) / Rm_mid; 
Qm_end = (Pa_end - Pv_end) / Rm_end; 

A1 = [(Rv_epi+R_PV/2), (R_PV/2), (R_PV/2)];
A2 = [(R_PV/2), (Rv_mid+R_PV/2), (R_PV/2)];
A3 = [(R_PV/2), (R_PV/2), (Rv_end+R_PV/2)];

A = [A1;A2;A3];
B = [Pv_epi - P_PV; 
    Pv_mid - P_PV; 
    Pv_end - P_PV];

X = A\B;

Qv_epi = double(X(1));
Qv_mid = double(X(2));
Qv_end = double(X(3));

Qv_epi = max(Qv_epi, 0);
Qv_mid = max(Qv_mid, 0);
Qv_end = max(Qv_end, 0);

Qim_a = Qa_epi + Qa_mid + Qa_end; 
Qim_v = Qv_epi + Qv_mid + Qv_end; 
Q_PV  = (P_PV - P_RA) / (R_PV / 2); 

%% Outputs 

dP_PA    = (Q_PA - Qim_a) / C_PA; 
dQ_PA    = (AoP - P_PA - Q_PA * R_PA) / L_PA; 
dPa_epi  = (Qa_epi - Qm_epi) / (cf_epi * Ca_epi) + dPim_epidt; 
dPa_mid  = (Qa_mid - Qm_mid) / (cf_mid * Ca_mid) + dPim_middt; 
dPa_end  = (Qa_end - Qm_end) / (Ca_end)          + dPim_enddt; 
dPv_epi  = (Qm_epi - Qv_epi) / (cf_epi * Cv)     + dPim_epidt; 
dPv_mid  = (Qm_mid - Qv_mid) / (cf_mid * Cv)     + dPim_middt; 
dPv_end  = (Qm_end - Qv_end) / (Cv)              + dPim_enddt;
dP_PV    = (Qim_v - Q_PV) / C_PV; 

dxdt = [dP_PA; dQ_PA; 
    dPa_epi; dPa_mid; dPa_end; 
    dPv_epi; dPv_mid; dPv_end; 
    dP_PV]; 

if flag == 0 
    outputs = []; 
else 
    outputs = [Va_epi; Va_mid; Va_end; 
        Vv_epi; Vv_mid; Vv_end; 
        Ra_epi; Ra_mid; Ra_end; 
        Rv_epi; Rv_mid; Rv_end; 
        Rm_epi; Rm_mid; Rm_end; 
        Qa_epi; Qa_mid; Qa_end; 
        Qm_epi; Qm_mid; Qm_end; 
        Qv_epi; Qv_mid; Qv_end; 
        Qim_a; Qim_v; 
        Q_PV]; 
end 








