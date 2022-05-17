

figures_on = 0; 

%% Load data 

% load ControlHem_OSS1150.mat ControlHem
load ControlHamidPaper.mat ControlHem 

k = 1; % Control 
Control = ControlHem.Data(k); 

%% Metabolic Signal 

MetOptions = {'QM'}; 

%% Read aortic and left venctricular pressure from excel file containing data

% Load time vector and heart rate/period 
t  = Control.Time; 
dt = Control.dt; 

% Load heart period and rate 
T  = Control.T; 
HR = Control.HR; 

% Load time series 
AoP    = Control.AoP; 
PLV    = Control.PLV; 
Flow   = Control.Flow; 
dPLVdt = Control.dPLVdt; 

M_AoP = max(AoP); 
m_AoP = min(AoP); 
[~,locs_M] = findpeaks(AoP,'MinPeakProminence',.5*(M_AoP - m_AoP)); 
[~,locs_m] = findpeaks(-AoP,'MinPeakProminence',.5*(M_AoP - m_AoP)); 

AoPmax = mean(AoP(locs_M)); 
AoPmin = mean(AoP(locs_m)); 
AoPbar = trapz(t(locs_m(end-3):locs_m(end-1)),AoP(locs_m(end-3):locs_m(end-1))) / (t(locs_m(end-1)) - t(locs_m(end-3))); 

M_Flow = max(Flow); 
m_Flow = min(Flow); 
[~,locs_M] = findpeaks(Flow,'MinPeakProminence',.5*(M_Flow - m_Flow)); 
[~,locs_m] = findpeaks(-Flow,'MinPeakProminence',.5*(M_Flow - m_Flow)); 

Flowmax = mean(Flow(locs_M)); 
Flowmin = mean(Flow(locs_m)); 
Flowbar = trapz(t(locs_m(end-3):locs_m(end-1)),Flow(locs_m(end-3):locs_m(end-1))) / (t(locs_m(end-1)) - t(locs_m(end-3)));

%% Construct data structure 

data.t = t; 
data.dt = dt; 
data.T = T; 
data.HR = HR; 
data.AoP = AoP; 
data.PLV = PLV; 
data.Flow = Flow; 
data.dPLVdt = dPLVdt; 

% Load interpolants 
data.AoPspl    = Control.AoPspl; 
data.PLVspl    = Control.PLVspl; 
data.dPLVdtspl = Control.dPLVdtspl; 

data.AoPmax = AoPmax; 
data.AoPmin = AoPmin; 
data.AoPbar = AoPbar; 
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
MVO2 = 60; % Rest MVO2
data.MVO2 = data.Exercise_LvL*MVO2; 

%% Initialize the parameters of the circulation model

pars = parameters(data);

%% Run the model 

Outputs = model_sol(pars,data); 

Q_PA = Outputs.Q_PA * 60; 
Qa_epi = Outputs.Qa_epi * 60; 
Qa_mid = Outputs.Qa_mid * 60; 
Qa_end = Outputs.Qa_end * 60; 

Pa_epi = Outputs.Pa_epi; 
Pa_mid = Outputs.Pa_mid;
Pa_end = Outputs.Pa_end; 

%% Plot figures 

h1 = figure(1); 
clf
hold on
plot(t,Qa_end,'b','LineWidth',2)
plot(t,Qa_mid,'g','LineWidth',2)
plot(t,Qa_epi,'r','LineWidth',2)
xlim([t(1) t(end)])
xlabel('Time (s)')
ylabel('Myocardial Flow (mL min^{-1})')
set(gca,'Fontsize',16)

h2 = figure(2);
clf
hold on
h(1) = plot(t,Q_PA,'linewidth',2);
h(2) = plot(t,Flow,'linewidth',3,'Color',[0 0 0 0.4]);
ylabel('Myocardial Flow (mL min^{-1})')
xlabel('Time (s)')
set(gca,'Fontsize',16)
xlim([t(1) t(end)])
legend([h(2),h(1)],{'Data','Model'},'Location','northeast')


h3 = figure(3);
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

h4 = figure(4);
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

if figures_on == 1
    if k == 1 
        print(h1,'-dpng','~/Dropbox/UMICH/Coronary/Figures/LayerFlow_Control.png')
        print(h2,'-dpng','~/Dropbox/UMICH/Coronary/Figures/Flow_Control.png')
        print(h3,'-dpng','~/Dropbox/UMICH/Coronary/Figures/Pressure_Control.png')
        print(h4,'-dpng','~/Dropbox/UMICH/Coronary/Figures/LayerPressure_Control.png')
    elseif k == 2
        print(h1,'-dpng','~/Dropbox/UMICH/Coronary/Figures/LayerFlow_H1.png')
        print(h2,'-dpng','~/Dropbox/UMICH/Coronary/Figures/Flow_H1.png')
        print(h3,'-dpng','~/Dropbox/UMICH/Coronary/Figures/Pressure_H1.png')
        print(h4,'-dpng','~/Dropbox/UMICH/Coronary/Figures/LayerPressure_H1.png')
    elseif k == 3
        print(h1,'-dpng','~/Dropbox/UMICH/Coronary/Figures/LayerFlow_H2.png')
        print(h2,'-dpng','~/Dropbox/UMICH/Coronary/Figures/Flow_H2.png')
        print(h3,'-dpng','~/Dropbox/UMICH/Coronary/Figures/Pressure_H2.png')
        print(h4,'-dpng','~/Dropbox/UMICH/Coronary/Figures/LayerPressure_H2.png')
    else
        print(h1,'-dpng','~/Dropbox/UMICH/Coronary/Figures/LayerFlow_H3.png')
        print(h2,'-dpng','~/Dropbox/UMICH/Coronary/Figures/Flow_H3.png')
        print(h3,'-dpng','~/Dropbox/UMICH/Coronary/Figures/Pressure_H3.png')
        print(h4,'-dpng','~/Dropbox/UMICH/Coronary/Figures/LayerPressure_H3.png')
    end 
end 