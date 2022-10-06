function [var_endo, var_mid, var_epi] = CycleAvg_Exercise(test, var)
% Calculates the cycle to cycle averages for different variables that are
% defined for all layers. Inputs are 
% test : the structure that includes each state of simulation
% (rest/exercise/init)
   
eval(['SubendoVar = test.Results.',var,'3;']);  %Q13 - Qa_end
eval(['MidVar = test.Results.',var,'2;']);      %Q12 - Qa_mid
eval(['SubepiVar = test.Results.',var,'1;']);   %Q11 - Qa_epi
eval(['t = test.Results.t;']);
eval('t_final = test.Results.t(end);');
eval('T = test.T;');

t_idx = t>t_final-2*T & t<=t_final;
Dt = diff(t);

SubendoVar = sum(SubendoVar(t_idx).*Dt(t_idx(2:end)))/(2*T);
var_endo = mean(SubendoVar);

MidVar = sum(MidVar(t_idx).*Dt(t_idx(2:end)))/(2*T);
var_mid = mean(MidVar);

SubepiVar = sum(SubepiVar(t_idx).*Dt(t_idx(2:end)))/(2*T);
var_epi = mean(SubepiVar);


