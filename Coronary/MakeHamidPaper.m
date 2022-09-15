
clear all
close all

%% Time Series Data 
% Choose first point to start in end diastole. Last point is the end of the
% data for the shortest data set 
% 
% Time = readmatrix('../ExerciseSimulation/TuneExercisePig.xlsx', ...
%     'Sheet','PhasicTracing',...
%     'Range','A9:A6019');

M_Base = readmatrix('../ExerciseSimulation/TuneExercisePig.xlsx', ...
    'Sheet','2713 Resting',...
    'Range','B9:D5005');

Time = 0:.002:(.002*length(M_Base(:,1))); 
Time = Time(1:length(M_Base(:,1)))'; 
Time = Time - Time(1); 

dt = mean(diff(Time)); 

%% Extract data 

Flow_B = M_Base(:,1); 
P_Ao_B  = M_Base(:,2); 
P_LV_B  = M_Base(:,3); 

%% Find mean of flows 

MeanFlow_B = mean(M_Base(:,1)); 

%% Smooth out PLV 

P_LV_B   = 0.85*(P_LV_B-17);
P_LV_B   = smoothdata(P_LV_B,'gaussian','smoothingfactor',0.015); 


%% Make Pressure Derivatives 

dP_LV_Bdt = diff(P_LV_B)/dt; 
dP_LV_Bdt = [dP_LV_Bdt(1); dP_LV_Bdt]; %Repeat the first term 

%% Make interpolants

P_Aospl_B    = griddedInterpolant(Time,P_Ao_B); 
P_LVspl_B    = griddedInterpolant(Time,P_LV_B); 
dP_LV_Bdtspl = griddedInterpolant(Time,dP_LV_Bdt); 

%% Make data structure 

ControlHem.Data(1).Time = Time - Time(1); 
ControlHem.Data(1).dt   = dt; 

ControlHem.Data(1).P_Ao       = P_Ao_B; 
ControlHem.Data(1).Flow       = Flow_B; 
ControlHem.Data(1).MeanFlow   = MeanFlow_B; 
ControlHem.Data(1).P_LV       = P_LV_B; 
ControlHem.Data(1).dP_LVdt    = dP_LV_Bdt; 
ControlHem.Data(1).P_Aospl    = P_Aospl_B; 
ControlHem.Data(1).P_LVspl    = P_LVspl_B; 
ControlHem.Data(1).dP_LVdtspl = dP_LV_Bdtspl; 


%% Point values

ControlHem.Data(1).LVWeight = 81.87; 

% Viscosity function from Snyder 1971 - Influence of temperature and hematocriton blood viscosity 
k0 = 0.0322;
k3 = 1.08*1e-4;
k2 = 0.02;
T = 37 ;
Viscosity = @(x) 2.03 * exp( (k0 - k3*T)*x - k2*T );

i = 1; 
ControlHem.Data(i).SBP      = [0]; %PointValues(i,1); 
ControlHem.Data(i).DBP      = [0]; %PointValues(i,2); 
ControlHem.Data(i).MBP      = [0]; %PointValues(i,3); 
ControlHem.Data(i).HR       = 84.45; %PointValues(i,4); 
ControlHem.Data(i).T        = 60/ControlHem.Data(i).HR; 
ControlHem.Data(i).CorFlow  = [0]; %PointValues(i,5); 
ControlHem.Data(i).P_LVmin  = [0]; %PointValues(i,7); 
ControlHem.Data(i).dPdtmax  = [0]; %PointValues(i,8);
ControlHem.Data(i).dPdtmin  = [0]; %PointValues(i,9); 
ControlHem.Data(i).tauhalf  = [0]; %PointValues(i,10);
ControlHem.Data(i).ArtO2Cnt = 13.6; %PointValues(i,11); 
ControlHem.Data(i).CVO2Cnt  = 5.2; %PointValues(i,12);
ControlHem.Data(i).ArtPO2   = 144; %PointValues(i,13); 
ControlHem.Data(i).CVPO2    = 20; %PointValues(i,14);
ControlHem.Data(i).ArtO2Sat = 100; %PointValues(i,15); 
ControlHem.Data(i).CVO2Sat  = 38.5; %PointValues(i,16);
ControlHem.Data(i).Hgb      = 10.1; %PointValues(i,17); 
ControlHem.Data(i).HCT      = 30; %PointValues(i,18);
ControlHem.Data(i).Vis      = Viscosity(ControlHem.Data(i).HCT); 
ControlHem.Data(i).VisRatio = Viscosity(ControlHem.Data(i).HCT)/Viscosity(31.5); 
ControlHem.Data(i).LAD_Epi  = [0]; %PointValues(i,19); 
ControlHem.Data(i).LAD_Mid  = [0]; %PointValues(i,20);
ControlHem.Data(i).LAD_Endo = [0]; %PointValues(i,21); 

save ControlHamidPaper.mat ControlHem



