% Driver that runs the optimization of the perfusion model 

printfigs_on = 0; % print plotted figures if printfigs_on = 1

addpath OPT

%% Load data 

load ControlHem_OSS1150.mat ControlHem
%load ControlHamidPaper.mat ControlHem 

k = 1; % Control = 1; Hemmorhage 1 = 2, Hem 2 = 3, Hem 3 = 4
Control = ControlHem.Data(k); 

%% Metabolic Signal 

MetOptions = {'QM'}; %We're only using this one from Hamid's paper

%% Read aortic and left venctricular pressure from excel file containing data

LVweight = Control.LVWeight;
scale = 1; %1 / LVweight; 

% Load time vector and heart rate/period 
t  = Control.Time; 
dt = Control.dt; 

% Load heart period and rate 
T  = Control.T; 
HR = Control.HR; 

% Load time series 
AoP    = Control.AoP; 
PLV    = Control.PLV; 
Flow   = Control.Flow / 60 * scale; 
dPLVdt = Control.dPLVdt; 

% Calculate max, min, and average pressure 
M_PLV = max(PLV); 
m_PLV = min(PLV); 
[~,locs_M] = findpeaks(PLV,'MinPeakProminence',.5*(M_PLV - m_PLV)); 
[~,locs_m] = findpeaks(-PLV,'MinPeakProminence',.5*(M_PLV - m_PLV)); 

PLV_M = mean(PLV(locs_M)); 
PLV_m = mean(PLV(locs_m)); 
PLVbar = trapz(t(locs_m(2):locs_m(end-1)),PLV(locs_m(2):locs_m(end-1))) / (t(locs_m(end-1)) - t(locs_m(2))); 

% Calculate max, min, and average pressure 
M_AoP = max(AoP); 
m_AoP = min(AoP); 
[~,locs_M] = findpeaks(AoP,'MinPeakProminence',.5*(M_AoP - m_AoP)); 
[~,locs_m] = findpeaks(-AoP,'MinPeakProminence',.5*(M_AoP - m_AoP)); 

AoP_M = mean(AoP(locs_M)); 
AoP_m = mean(AoP(locs_m)); 
AoPbar = trapz(t(locs_m(2):locs_m(end-1)),AoP(locs_m(2):locs_m(end-1))) / (t(locs_m(end-1)) - t(locs_m(2))); 

% Calculate max, min, and average flow 
M_Flow = max(Flow); 
m_Flow = min(Flow); 
[~,locs_M] = findpeaks(Flow,'MinPeakProminence',.5*(M_Flow - m_Flow)); 
[~,locs_m] = findpeaks(-Flow,'MinPeakProminence',.5*(M_Flow - m_Flow)); 

Flow_M = mean(Flow(locs_M)); 
Flow_m = mean(Flow(locs_m)); 
Flowbar = trapz(t(locs_m(2):locs_m(end-1)),Flow(locs_m(2):locs_m(end-1))) / (t(locs_m(end-1)) - t(locs_m(2)));


% Find time points when P_LV is in diastole 
M_dPLVdt = max(dPLVdt); 
m_dPLVdt = min(dPLVdt); 
[~,locs_M] = findpeaks(dPLVdt,'MinPeakProminence',.5*(M_dPLVdt - m_dPLVdt)); 
[~,locs_m] = findpeaks(-dPLVdt,'MinPeakProminence',.5*(M_dPLVdt - m_dPLVdt)); 

if locs_M(1) < locs_m(1)
    for i = 1:min(length(locs_m),length(locs_M))
        Flow_base_vec(i) = mean(Flow(locs_M(i):locs_m(i))); 
    end 
else 
    for i = 1:min(length(locs_m),length(locs_M))
        Flow_base_vec(i) = mean(Flow(locs_M(i):locs_m(i+1))); 
    end 
end 
Flow_base = mean(Flow_base_vec); 

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

data.PLV_M   = PLV_M; 
data.PLV_m   = PLV_m; 
data.PLVbar  = PLVbar; 
data.AoP_M   = AoP_M; 
data.AoP_m   = AoP_m; 
data.AoPbar  = AoPbar; 
data.Flow_M  = Flow_M; 
data.Flow_m  = Flow_m; 
data.Flowbar = Flowbar; 
data.Flow_base = Flow_base; 

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

[scalepars,UB,LB,data] = parameters_scaling(data); 

%% Set global parameters for optimization

INDMAP = [1 2 3 4 5]; % gamma

ALLPARS  = scalepars;
ODE_TOL  = 1e-8; 
DIFF_INC = sqrt(ODE_TOL);

gpars.INDMAP   = INDMAP;
gpars.ALLPARS  = ALLPARS;
gpars.ODE_TOL  = ODE_TOL;
gpars.DIFF_INC = DIFF_INC;

data.gpars = gpars;

%% Optimization - levenberg-marquardt

optx   = scalepars(INDMAP); 
opthi  = UB(INDMAP);
optlow = LB(INDMAP);

maxiter = 40; 
mode    = 2; 
nu0     = 2.d-1; 

[xopt, histout, costdata, jachist, xhist, rout, sc] = ...
     newlsq_v2(optx,'opt_wrap',1.d-4,maxiter,...
     mode,nu0,opthi,optlow,data); 

%% Solve model 

optpars = scalepars; 
optpars(INDMAP) = xopt; 

pars = parameters(optpars,data); 
outputs = model_sol(pars,data); 

% % Save optimized parameters in a .mat file 
% if ~exist('Results','dir')
%     mkdir('Results')
% end 
% save Results/optpars.mat optpars data outputs

%% Display optimized parameters 

pars_opt = exp(optpars);
disp('optimized gamma')
disp([INDMAP' pars_opt(INDMAP)])

%% Plots

elapsed_time = toc;
elapsed_time = elapsed_time/60


h1 = figure(11); 
clf
hold on
plot(t,Qa_end,'b','LineWidth',2)
plot(t,Qa_mid,'g','LineWidth',2)
plot(t,Qa_epi,'r','LineWidth',2)
xlim([t(1) t(end)])
xlabel('Time (s)')
ylabel('Myocardial Flow (mL min^{-1})')
set(gca,'Fontsize',16)

h2 = figure(12);
clf
hold on
h(1) = plot(t,Q_PA,'linewidth',2);
h(2) = plot(t,Flow * 60 / scale,'linewidth',3,'Color',[0 0 0 0.4]);
ylabel('Myocardial Flow (mL min^{-1})')
xlabel('Time (s)')
set(gca,'Fontsize',16)
xlim([t(1) t(end)])
legend([h(2),h(1)],{'Data','Model'},'Location','northeast')


h3 = figure(13);
clf
hold on
plot(t,AoP,'linewidth',1.5)
plot(t,PLV,'Color',[1 0 0 0.4],'linewidth',1.5)
ylabel('Pressure (mmHg)')
xlabel('Time (s)')
legend('Aortic','LV','Location','southwest')
set(gca,'Fontsize',16)
xlim([t(1) t(end)])
ylim([-10 180])

h4 = figure(14);
clf
hold on
plot(t,Pa_end,'b','LineWidth',2)
plot(t,Pa_mid,'g','LineWidth',2)
plot(t,Pa_epi,'r','LineWidth',2)
plot(t,PLV,'Color',[0 0 0 0.2],'linewidth',1.5)
xlim([t(1) t(end)])
xlabel('Time (s)')
ylabel('Pressure (mmHg)')
legend('subendo','midwall','subepi','location','best')
set(gca,'Fontsize',16)

