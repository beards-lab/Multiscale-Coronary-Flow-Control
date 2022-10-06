function [dxdt,outputs] = dxdt_repvessel(t, x, params, HR, Ptm_bar, MetSignal,flag)
%{
Right hand side of the representative vessel model. 
Inputs: 
    t - time 
    x - states
    params - adjustable parameter vector 
    HR - heart rate 
    Ptm_bar - mean transmural pressure at a specific layer 
    MetSignal - metabolic signal at a specific layer 
    flag - if flag = 0, solves ODE system. If flag = 1, produces auxiliary
    equation outputs
Outputs: 
    dxdt - right hand side of the ODEs 
    outputs - calculations of other auxiliary equations 
%} 


%% Parameters

Cp    = params(1); 
Ap    = params(2); 
Bp    = params(3); 
phi_p = params(4); 
phi_m = params(5); 
Cm    = params(6); 
rho_m = params(7); 
C_myo = params(8); 
C_met = params(9); 
C_HR  = params(10); 
C0    = params(11); 
HR0   = params(12);
gD    = params(13); 
gA    = params(14); 

%% States

D = x(1); 
A = x(2); 

R = D/2; 
T = Ptm_bar*R; 

%% Auxiliary equations 

%R0 = (Ap - Bp) / pi * ( atan(-phi_p / Cp) + pi/2 ) + Bp; 

T_pas = R * (phi_p + Cp * (tan(pi * (R - Bp) ./ (Ap - Bp) - pi/2))); 
T_max = rho_m * R * exp( -((R - phi_m)/Cm)^2); 

S_myo = max(0, C_myo * T * 133.32 / 1e6); 
S_met = C_met * MetSignal; 
S_HR  = C_HR * max(0, HR - HR0); 
S = S_myo - S_met - S_HR + C0; 

A_tot = 1 / (1 + exp(-S)); 
T_tot = T_pas + A * T_max; 

%% ODEs 

dD = gD * (T - T_tot); 
dA = gA * (A_tot - A); 

%% Outputs 

dxdt = [dD; dA]; 

if flag == 0
    outputs = []; 
else 
    outputs = [R; T; T_pas; T_max; 
        S_myo; S_met; S_HR; S; 
        A_tot; T_tot; 
        ]; 
end 





