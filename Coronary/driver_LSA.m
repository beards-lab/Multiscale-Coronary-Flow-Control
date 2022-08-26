% Driver that runs the LSA of the perfusion model 

printfigs_on = 0; % print plotted figures if printfigs_on = 1

addpath LSA

%% Load data 

load ControlHem_OSS1150.mat ControlHem
%load ControlHamidPaper.mat ControlHem 

k = 1; % Control = 1; Hemmorhage 1 = 2, Hem 2 = 3, Hem 3 = 4
Control = ControlHem.Data(k); 

%% Metabolic Signal 

MetOptions = {'QM'}; %We're only using this one from Hamid's paper

%% Read aortic and left venctricular pressure from excel file containing data

LVweight = Control.LVWeight;
scale = 1 / LVweight; 

% Load time vector and heart rate/period 
t  = Control.Time; 
dt = Control.dt; 

% Load heart period and rate 
T  = Control.T; 
HR = Control.HR; 

% Load time series 
AoP    = Control.AoP; 
PLV    = Control.PLV; 
Flow   = Control.Flow * scale; 
dPLVdt = Control.dPLVdt; 

% Calculate max, min, and average pressure 
M_AoP = max(AoP); 
m_AoP = min(AoP); 
[~,locs_M] = findpeaks(AoP,'MinPeakProminence',.5*(M_AoP - m_AoP)); 
[~,locs_m] = findpeaks(-AoP,'MinPeakProminence',.5*(M_AoP - m_AoP)); 

AoPmax = mean(AoP(locs_M)); 
AoPmin = mean(AoP(locs_m)); 
AoPbar = trapz(t(locs_m(2):locs_m(end-1)),AoP(locs_m(2):locs_m(end-1))) / (t(locs_m(end-1)) - t(locs_m(2))); 

% Calculate max, min, and average flow 
M_Flow = max(Flow); 
m_Flow = min(Flow); 
[~,locs_M] = findpeaks(Flow,'MinPeakProminence',.5*(M_Flow - m_Flow)); 
[~,locs_m] = findpeaks(-Flow,'MinPeakProminence',.5*(M_Flow - m_Flow)); 

Flowmax = mean(Flow(locs_M)); 
Flowmin = mean(Flow(locs_m)); 
Flowbar = trapz(t(locs_m(2):locs_m(end-1)),Flow(locs_m(2):locs_m(end-1))) / (t(locs_m(end-1)) - t(locs_m(2)));

%% Construct data structure 

data.t        = t; 
data.dt       = dt; 
data.T        = T; 
data.HR       = HR; 
data.AoP      = AoP; 
data.PLV      = PLV; 
data.Flow     = Flow; 
data.dPLVdt   = dPLVdt; 
data.LVweight = LVweight; 

% Load interpolants 
data.AoPspl    = Control.AoPspl; 
data.PLVspl    = Control.PLVspl; 
data.dPLVdtspl = Control.dPLVdtspl; 

data.AoPmax  = AoPmax; 
data.AoPmin  = AoPmin; 
data.AoPbar  = AoPbar; 
data.Flowmax = Flowmax; 
data.Flowmin = Flowmin; 
data.Flowbar = Flowbar; 

% Load blood gas measurements 
data.ArtO2Cnt   = Control.ArtO2Cnt;
data.CVO2Cnt    = Control.CVO2Cnt;
data.ArtPO2     = Control.ArtPO2;
data.CvPO2      = Control.CVPO2;
data.ArtO2Sat   = Control.ArtO2Sat;
data.CvO2Sat    = Control.CVO2Sat;
data.Hgb        = Control.Hgb;
data.HCT        = Control.HCT;
data.VisRatio   = Control.VisRatio;

% Load heart weight 
data.LVweight   = Control.LVWeight;

% structure init is formed to initialize the rest structure.
data.Exercise_LvL = 1.00; % 1.00 means no exercise, MVO2 remains unchanged
MVO2      = 60; % Rest MVO2
data.MVO2 = data.Exercise_LvL*MVO2; 

data.printfigs_on = printfigs_on; 

%% Get nominal parameter values

%Global parameters
ODE_TOL  = 1e-8;
DIFF_INC = sqrt(ODE_TOL);

gpars.ODE_TOL  = ODE_TOL;
gpars.DIFF_INC = DIFF_INC; 

data.gpars = gpars; 

%% Get parameters 

[scalepars,data] = parameters_scaling(data); 

%% Sensitivity Analysis

% senseq finds calculates the sensitivity equations for each parameter 
sens = senseq(scalepars,data);
sens = abs(sens); 

% Take norm and rank sensitivities
[M,N] = size(sens);
sens_norm = zeros(N,1); 
for i = 1:N 
    sens_norm(i)=norm(sens(:,i),2);
end

[Rsens,Isens] = sort(sens_norm,'descend');
display([Isens]); 

%% Plots 

t_idx = t>t(end)-5*T & t<=t(end);

figure(100)
clf
plot(t(t_idx),sens(1:end-1,:))
legend('a','b','c','d','e')

plot_LSA(Rsens,Isens,data)



% %% Save workspace 
% 
% % Get a list of all variables
% allvars = whos;
% 
% % Identify the variables that ARE NOT graphics handles. This uses a regular
% % expression on the class of each variable to check if it's a graphics object
% tosave = cellfun(@isempty, regexp({allvars.class}, '^matlab\.(ui|graphics)\.'));
% 
% % Pass these variable names to save
% if ~exist('Results','dir')
%     mkdir('Results')
% end
% save('Results/sens.mat', allvars(tosave).name)
% 
% elapsed_time = toc
