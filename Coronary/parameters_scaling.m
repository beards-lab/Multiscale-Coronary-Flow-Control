function [scalepars,UB,LB,data] = parameters_scaling(data) 

% These are scaling factors that Hamid had in his code 
a = 5; %3; % for the compliance of the penetrating artery and vein  
b = .05; %9; % for the compliance and zero-pressure volumes of the myocardial layers 

% This is a scaling factor that I implemented for the Hem data
%c = 5; 
c = 1; % for the resistances throughout the myocardial layers 

% These scaling factors are implemented to get the right ENDO/EPI ratio for
% Hamid's data. The model compliance factors were originally in the wrong
% place in the dxdt_myocardium.m code 
d = 1; % for the epi/end compliance and resistance 
e = 1; % for the epi/mid compliance and resistance 

scalepars = [a; b; c; d; e];

UB = scalepars*5; 
LB = scalepars/5; 

data.pars_names = {'a','b','c','d','e'}; 