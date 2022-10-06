function outputs = model_sol_repvessel(pars,data,outputs)
%{ 
Calls the representative vessel model and solver and then compiles all of 
the outputs 
Inputs: 
    pars - parameter vector 
    data - data structure loaded in 
    outputs - output structure from the perfusion model 
Outputs: 
    outputs - output structure compiling all results 
    
%} 

%% 

R_MVO2 = 1.5; % Endo to Epi MVO2 ratio

% Oxygen consumption 
M_tot = data.Exercise_LvL * data.MVO2; 
M_epi = 1 / ((3/2) * (R_MVO2 + 1)); 
M_mid = ((R_MVO2 + 1) / 2) / ((3/2) * (R_MVO2 + 1)); 
M_end = R_MVO2 / ((3/2) * R_MVO2 + 1); 

MVO2_epi = M_tot * M_epi; 
MVO2_mid = M_tot * M_mid; 
MVO2_end = M_tot * M_end; 

% Metabolic signal 
outputs.epi.MetSignal = MVO2_epi * outputs.epi.Qa_bar; 
outputs.mid.MetSignal = MVO2_mid * outputs.mid.Qa_bar; 
outputs.end.MetSignal = MVO2_end * outputs.end.Qa_bar; 

X0 = [100; 0.5]; 

%% Solve reperfusion model for epicardial layer 

params_epi = pars.repvessel.epi.params; 

sol_epi = ode15s(@dxdt_repvessel, [0 200], X0, [], params_epi, data.HR, ...
    outputs.epi.Ptm_bar, outputs.epi.MetSignal,0);

[~,o_epi] = dxdt_repvessel(sol_epi.x(end), sol_epi.y(end,:), params_epi, data.HR, ...
    outputs.epi.Ptm_bar, outputs.epi.MetSignal,1); 

outputs.epi.D     = sol_epi.y(1,end); 
outputs.epi.A     = sol_epi.y(2,end); 
outputs.epi.S_myo = o_epi(5); 
outputs.epi.S_met = o_epi(6); 
outputs.epi.S_HR  = o_epi(7); 

%% Solve reperfusion model for mid layer 

params_mid = pars.repvessel.mid.params; 

sol_mid = ode15s(@dxdt_repvessel, [0 200], X0, [], params_mid, data.HR, ...
    outputs.mid.Ptm_bar, outputs.mid.MetSignal,0);

[~,o_mid] = dxdt_repvessel(sol_mid.x(end), sol_mid.y(end,:), params_mid, data.HR, ...
    outputs.mid.Ptm_bar, outputs.mid.MetSignal,1); 

outputs.mid.D     = sol_mid.y(1,end); 
outputs.mid.A     = sol_mid.y(2,end); 
outputs.mid.S_myo = o_mid(5); 
outputs.mid.S_met = o_mid(6); 
outputs.mid.S_HR  = o_mid(7); 

%% Solve reperfusion model for mid layer 

params_end = pars.repvessel.end.params; 

sol_end = ode15s(@dxdt_repvessel, [0 200], X0, [], params_end, data.HR, ...
    outputs.end.Ptm_bar, outputs.end.MetSignal,0);

[~,o_end] = dxdt_repvessel(sol_end.x(end), sol_end.y(end,:), params_end, data.HR, ...
    outputs.end.Ptm_bar, outputs.end.MetSignal,1); 

outputs.end.D     = sol_end.y(1,end); 
outputs.end.A     = sol_end.y(2,end); 
outputs.end.S_myo = o_end(5); 
outputs.end.S_met = o_end(6); 
outputs.end.S_HR  = o_end(7); 






