% Driver that runs the forward perfusion model 

clear all

printfigs_on = 0; % print plotted figures if printfigs_on = 1

%% Load data and parameters 

load OSS_1150_data.mat 

scale = 100 / Data.LVweight;

data            = Data.BL; 
data.scale      = scale; 
data.dt         = mean(diff(data.Time)); 
data.Q_myo      = data.Q_myo      / 60 * scale; 
data.Q_myo_M    = data.Q_myo_M    / 60 * scale; 
data.Q_myo_m    = data.Q_myo_m    / 60 * scale; 
data.Q_myo_base = data.Q_myo_base / 60 * scale; 
data.Q_myo_bar  = data.Q_myo_bar  / 60 * scale; 

% Initialize the parameters from control state 
[pars,~,~,data] = parameters(data); 

% structure init is formed to initialize the rest structure.
data.Exercise_LvL = 1.00; % 1.00 means no exercise, MVO2 remains unchanged
MVO2      = 60; % Rest MVO2
data.MVO2 = data.Exercise_LvL*MVO2; 

%% Run the model 

Outputs = model_sol(pars,data); 

%% Vectors for figures 

scale = data.scale; 
Time  = data.Time; 
Q_myo = data.Q_myo * 60 / scale; 
P_LV  = data.P_LV; 
P_Ao  = data.P_Ao; 

% Scale flows to mL min^{-1}
Q_PA   = Outputs.Q_PA   * 60 / scale; 
Qa_epi = Outputs.Qa_epi * 60 / scale; 
Qa_mid = Outputs.Qa_mid * 60 / scale; 
Qa_end = Outputs.Qa_end * 60 / scale; 

P_PA   = Outputs.P_PA; 
Pa_epi = Outputs.Pa_epi; 
Pa_mid = Outputs.Pa_mid;
Pa_end = Outputs.Pa_end; 

%% Plot figures 

h1 = figure(11); 
clf
hold on
plot(Time,Qa_end,'b','LineWidth',2)
plot(Time,Qa_mid,'g','LineWidth',2)
plot(Time,Qa_epi,'r','LineWidth',2)
xlim([Time(1) Time(end)])
xlabel('Time (s)')
ylabel('Myocardial Flow (mL min^{-1})')
set(gca,'Fontsize',16)

h2 = figure(12);
clf
hold on
h(1) = plot(Time,Q_PA,'linewidth',2);
h(2) = plot(Time,Q_myo,'linewidth',3,'Color',[0 0 0 0.4]);
ylabel('Myocardial Flow (mL min^{-1})')
xlabel('Time (s)')
set(gca,'Fontsize',16)
xlim([Time(1) Time(end)])
legend([h(2),h(1)],{'Data','Model'},'Location','northeast')

h3 = figure(13);
clf
hold on
plot(Time,P_Ao,'linewidth',1.5)
plot(Time,P_LV,'Color',[1 0 0 0.4],'linewidth',1.5)
%plot(t,P_PA,'r','linewidth',1.5)
ylabel('Pressure (mmHg)')
xlabel('Time (s)')
legend('Aortic','LV','Location','southwest')
set(gca,'Fontsize',16)
xlim([Time(1) Time(end)])
ylim([-10 180])

h4 = figure(14);
clf
hold on
plot(Time,Pa_end,'b','LineWidth',2)
plot(Time,Pa_mid,'g','LineWidth',2)
plot(Time,Pa_epi,'r','LineWidth',2)
plot(Time,P_LV,'Color',[0 0 0 0.2],'linewidth',1.5)
xlim([Time(1) Time(end)])
xlabel('Time (s)')
ylabel('Pressure (mmHg)')
legend('subendo','midwall','subepi','location','best')
set(gca,'Fontsize',16)

if printfigs_on == 1
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