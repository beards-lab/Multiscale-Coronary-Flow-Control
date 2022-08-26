function [Outputs,rout,J] = model_sol(pars,data)
%{ 
Calls the model and solver and then compiles all of the outputs 
Inputs: 
    pars - parameter vector 
    data - data structure loaded in 
Outputs: 
    Outputs - output structure compiling all results 
%} 

pars = exp(pars); 

%% Load in data structure 

t = data.t; 
t_final = t(end); 
dt = data.dt; 
T = data.T; 

AoP_M = data.AoP_M;

%% Get initial conditions 

% Initial conditions scaled by the average diastolic AoP for each
% case. Avg baseline for this pig is 96. (Should have code to extract this
% soon) 
Init = [data.AoP(1); 
    data.Flow(1); 
    data.AoP(1) * (50  / 120); 
    data.AoP(1) * (85  / 120); 
    data.AoP(1) * (115 / 120); 
    data.AoP(1) * (50  / 120); 
    data.AoP(1) * (85  / 120); 
    data.AoP(1) * (115 / 120);
    5; 
    ]; 

%% Solve the model 

sol  = ode15s(@dxdt_myocardium,[0 t_final],Init, [], pars, data, 0);
sols = deval(t,sol); 
sols = sols'; 

%% Get auxiliary outputs 

o = zeros(length(t),27); 
for i = 1:length(t)
    [~,o(i,:)] = dxdt_myocardium(t(i),sols(i,:),pars,data,1); 
end 

%% Compile results in a data structure 

Outputs.t      = t; 
Outputs.P_PA   = sols(:,1); % penetrating artery pressure
Outputs.Q_PA   = sols(:,2); % inlet flow penetrating artery
Outputs.Pa_epi = sols(:,3);
Outputs.Pa_mid = sols(:,4);
Outputs.Pa_end = sols(:,5);
Outputs.Pv_epi = sols(:,6);
Outputs.Pv_mid = sols(:,7);
Outputs.Pv_end = sols(:,8);
Outputs.P_PV   = sols(:,9); % penetrating vein pressure

Outputs.Va_epi = o(:,1); 
Outputs.Va_mid = o(:,2); 
Outputs.Va_end = o(:,3); 

Outputs.Vv_epi = o(:,4); 
Outputs.Vv_mid = o(:,5); 
Outputs.Vv_end = o(:,6); 

Outputs.Ra_epi = o(:,7); 
Outputs.Ra_mid = o(:,8); 
Outputs.Ra_end = o(:,9); 

Outputs.Rv_epi = o(:,10); 
Outputs.Rv_mid = o(:,11); 
Outputs.Rv_end = o(:,12); 

Outputs.Rm_epi = o(:,13); 
Outputs.Rm_mid = o(:,14);
Outputs.Rm_end = o(:,15); 

Outputs.Qa_epi = o(:,16); 
Outputs.Qa_mid = o(:,17); 
Outputs.Qa_end = o(:,18); 

Outputs.Qm_epi = o(:,19); 
Outputs.Qm_mid = o(:,20); 
Outputs.Qm_end = o(:,21); 

Outputs.Qv_epi = o(:,22); 
Outputs.Qv_mid = o(:,23); 
Outputs.Qv_end = o(:,24); 

Outputs.Qim_a = o(:,25); 
Outputs.Qim_v = o(:,26); 
Outputs.Q_PV  = o(:,27); 

%% Ratios 

t_idx = t>t_final-2*T & t<=t_final;

%Qendo = Results.Q13(t>t_final-2*T & t<=t_final);
Qendo = sum(Outputs.Qa_end(t_idx).*dt)/(2*T);

%Qmid = Results.Q12(t>t_final-2*T & t<t_final);
Qmid = sum(Outputs.Qa_mid(t_idx).*dt)/(2*T);

%Qepi = Results.Q11(t>t_final-2*T & t<t_final);
Qepi = sum(Outputs.Qa_epi(t_idx).*dt)/(2*T);

Outputs.ENDOEPI = Qendo/Qepi;
Outputs.ENDOMID = Qendo/Qmid;

disp(['ENDO/EPI = ',num2str(Qendo/Qepi)]);    

%% Cost function 


Flow_cost = data.Flow(t_idx); 
Q_PA_cost = Outputs.Q_PA(t_idx); 

% Since the flows can be negative, shift the flow profiles above zero so as
% not to divide by zero in residual 
Flow_cost = Flow_cost + 1.1*abs(min(Flow_cost)); 
Q_PA_cost = Q_PA_cost + 1.1*abs(min(Flow_cost));

rout1 = (Q_PA_cost - Flow_cost)./Flow_cost/sqrt(length(Flow_cost));  
rout2 = Qendo/Qepi - 1.25; 

rout = [rout1; rout2]; 
J = rout'*rout; 

