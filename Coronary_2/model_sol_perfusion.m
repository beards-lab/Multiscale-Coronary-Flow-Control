function [outputs,rout,J] = model_sol_perfusion(pars,data)
%{ 
Calls the perfusion model and solver and then compiles all of the outputs 
Inputs: 
    pars - parameter vector 
    data - data structure loaded in 
Outputs: 
    Outputs - output structure compiling all results 
    
%} 

params = exp(pars.perfusion.params); 

%% Load in data structure 

Time = data.Time; 
t_final = Time(end); 
T = data.T; 

%% Get initial conditions 

% Initial conditions scaled by the average diastolic AoP for each
% case. Avg baseline for this pig is 96. (Should have code to extract this
% soon) 

Init = initialconditions(data); 

%% Solve the model 

sol  = ode15s(@dxdt_perfusion,[0 t_final],Init, [], params, data, 0);
sols = deval(Time,sol); 
sols = sols'; 

%% Get auxiliary outputs 

o = zeros(length(Time),30); 
for i = 1:length(Time)
    [~,o(i,:)] = dxdt_perfusion(Time(i),sols(i,:),params,data,1); 
end 

%% Compile results in a data structure 

outputs.Time  = Time; 
outputs.P_PA  = sols(:,1);  % penetrating artery pressure
outputs.Q_PA  = sols(:,2);  % penetrating artery flow
outputs.P_PV  = sols(:,9);  % penetrating vein pressure
outputs.Q_PV  = o(:,27);    % penetrating vein flow 
outputs.Qim_a = o(:,25);    % arterial intramyocardial flow 
outputs.Qim_v = o(:,26);    % venous intramyocardial flow

% Arterial pressure
outputs.epi.Pa = sols(:,3);
outputs.mid.Pa = sols(:,4);
outputs.end.Pa = sols(:,5);

% Venous pressure
outputs.epi.Pv = sols(:,6);
outputs.mid.Pv = sols(:,7);
outputs.end.Pv = sols(:,8);

% Arterial volume
outputs.epi.Va = o(:,1); 
outputs.mid.Va = o(:,2); 
outputs.end.Va = o(:,3); 

% Venous volume
outputs.epi.Vv = o(:,4); 
outputs.mid.Vv = o(:,5); 
outputs.end.Vv = o(:,6); 

% Arterial resistance
outputs.epi.Ra = o(:,7); 
outputs.mid.Ra = o(:,8); 
outputs.end.Ra = o(:,9); 

% Venous resistance
outputs.epi.Rv = o(:,10); 
outputs.mid.Rv = o(:,11); 
outputs.end.Rv = o(:,12); 

% Capillary resistance 
outputs.epi.Rm = o(:,13); 
outputs.mid.Rm = o(:,14);
outputs.end.Rm = o(:,15); 

% Arterial flow 
outputs.epi.Qa = o(:,16); 
outputs.mid.Qa = o(:,17); 
outputs.end.Qa = o(:,18); 

% Capillary flow 
outputs.epi.Qm = o(:,19); 
outputs.mid.Qm = o(:,20); 
outputs.end.Qm = o(:,21); 

% Venous flow
outputs.epi.Qv = o(:,22); 
outputs.mid.Qv = o(:,23); 
outputs.end.Qv = o(:,24); 

% Intramyocardial pressure 
outputs.epi.Pim = o(:,28); 
outputs.mid.Pim = o(:,29); 
outputs.end.Pim = o(:,30); 

%% Results processing  

% Take last 4 periods 
i_4per = Time>t_final-4*T & Time<=t_final;
outputs.i_4per     = i_4per; 

% Find mean flow through each layer 
outputs.epi.Qa_bar = mean(outputs.epi.Qa(i_4per));
outputs.mid.Qa_bar = mean(outputs.mid.Qa(i_4per));
outputs.end.Qa_bar = mean(outputs.end.Qa(i_4per));

% Mean arterial layer pressure (was Pc)
outputs.epi.Pa_bar = mean(outputs.epi.Pa(i_4per)); 
outputs.mid.Pa_bar = mean(outputs.mid.Pa(i_4per)); 
outputs.end.Pa_bar = mean(outputs.end.Pa(i_4per)); 

% Average of penetrating artery pressure and arterial layer pressure (?)
% (Was Pl) 
outputs.epi.Pa_ave = (outputs.P_PA + outputs.epi.Pa)/2; 
outputs.mid.Pa_ave = (outputs.P_PA + outputs.mid.Pa)/2; 
outputs.end.Pa_ave = (outputs.P_PA + outputs.end.Pa)/2; 

% Compliant pressure (?) 
outputs.epi.PC = outputs.epi.Pa - outputs.epi.Pim; 
outputs.mid.PC = outputs.mid.Pa - outputs.mid.Pim; 
outputs.end.PC = outputs.end.Pa - outputs.mid.Pim; 

% Mean transmural pressure (was Ptm)
outputs.epi.Ptm_bar = mean(outputs.epi.Pa_ave(i_4per) - outputs.epi.Pim(i_4per)); 
outputs.mid.Ptm_bar = mean(outputs.mid.Pa_ave(i_4per) - outputs.mid.Pim(i_4per)); 
outputs.end.Ptm_bar = mean(outputs.end.Pa_ave(i_4per) - outputs.end.Pim(i_4per)); 

% Mean compliant pressure (?) (was PC) 
outputs.epi.PC_bar = mean(outputs.epi.Pa(i_4per) - outputs.epi.Pim(i_4per)); 
outputs.mid.PC_bar = mean(outputs.mid.Pa(i_4per) - outputs.mid.Pim(i_4per)); 
outputs.end.PC_bar = mean(outputs.end.Pa(i_4per) - outputs.end.Pim(i_4per)); 

% Equivalent diameter calculation 
outputs.epi.D = 100 * (outputs.mid.Ra ./ outputs.epi.Ra).^(1/4); 
outputs.mid.D = 100 * (outputs.mid.Ra ./ outputs.mid.Ra).^(1/4); 
outputs.mid.D = 100 * (outputs.mid.Ra ./ outputs.end.Ra).^(1/4); 

%% Cost function 

Q_myo_cost = data.Q_myo(i_4per); 
Q_PA_cost = outputs.Q_PA(i_4per); 

% Since the flows can be negative, shift the flow profiles above zero so as
% not to divide by zero in residual 
Q_myo_cost = Q_myo_cost + 1.1*abs(min(Q_myo_cost)); 
Q_PA_cost = Q_PA_cost + 1.1*abs(min(Q_myo_cost));

rout1 = (Q_PA_cost - Q_myo_cost)./Q_myo_cost/sqrt(length(Q_myo_cost));  
rout2 = outputs.end.Qa_bar/outputs.epi.Qa_bar - 1.25; 

rout = [rout1; rout2]; 
J = rout'*rout; 

