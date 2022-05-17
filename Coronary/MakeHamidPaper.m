
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
AoP_B  = M_Base(:,2); 
PLV_B  = M_Base(:,3); 

%% Find mean of flows 

MeanFlow_B = mean(M_Base(:,1)); 
% MeanFlow_H1 = mean(M_Hem1(:,2)); 
% MeanFlow_H2 = mean(M_Hem2(:,2)); 
% MeanFlow_H3 = mean(M_Hem3(:,2)); 

%% Smooth out PLV 

PLV_B   = 0.85*(PLV_B-17);
PLV_B   = smoothdata(PLV_B,'gaussian','smoothingfactor',0.015); 

%PLV_B = smoothdata(M_Base(:,3),'gaussian','smoothingfactor',0.015); %smoothing makes the numerics easier
% PLV_H1 = smoothdata(M_Hem1(:,3),'gaussian','smoothingfactor',0.015); %smoothing makes the numerics easier
% PLV_H2 = smoothdata(M_Hem2(:,3),'gaussian','smoothingfactor',0.015); %smoothing makes the numerics easier
% PLV_H3 = smoothdata(M_Hem3(:,3),'gaussian','smoothingfactor',0.015); %smoothing makes the numerics easier


%% Make Pressure Derivatives 

dPLV_Bdt = diff(PLV_B)/dt; 
dPLV_Bdt = [dPLV_Bdt(1); dPLV_Bdt]; %Repeat the first term 

%% Make interpolants

AoPspl_B    = griddedInterpolant(Time,AoP_B); 
PLVspl_B    = griddedInterpolant(Time,PLV_B); 
dPLV_Bdtspl = griddedInterpolant(Time,dPLV_Bdt); 

%% Make data structure 

ControlHem.Data(1).Time = Time - Time(1); 
ControlHem.Data(1).dt   = dt; 

ControlHem.Data(1).AoP       = AoP_B; 
ControlHem.Data(1).Flow      = Flow_B; 
ControlHem.Data(1).MeanFlow  = MeanFlow_B; 
ControlHem.Data(1).PLV       = PLV_B; 
ControlHem.Data(1).dPLVdt    = dPLV_Bdt; 
ControlHem.Data(1).AoPspl    = AoPspl_B; 
ControlHem.Data(1).PLVspl    = PLVspl_B; 
ControlHem.Data(1).dPLVdtspl = dPLV_Bdtspl; 

% ControlHem.Data(2).AoP      = M_Hem1(:,1); 
% ControlHem.Data(2).Flow     = M_Hem1(:,2); 
% ControlHem.Data(2).MeanFlow = MeanFlow_H1; 
% ControlHem.Data(2).PLV      = PLV_H1; 
% 
% ControlHem.Data(3).AoP      = M_Hem2(:,1); 
% ControlHem.Data(3).Flow     = M_Hem2(:,2); 
% ControlHem.Data(3).MeanFlow = MeanFlow_H2;  
% ControlHem.Data(3).PLV      = PLV_H2; 
% 
% ControlHem.Data(4).AoP      = M_Hem3(:,1); 
% ControlHem.Data(4).Flow     = M_Hem3(:,2); 
% ControlHem.Data(4).MeanFlow = MeanFlow_H3; 
% ControlHem.Data(4).PLV      = PLV_H3;


%% Point values
 
% LVWeight = readmatrix('06092021_Control_Hemorrhage_OSS1150.xlsx',...
%     'Sheet','AveragedData',...
%     'Range','B2:B2'); 

% PointValues = readmatrix('06092021_Control_Hemorrhage_OSS1150.xlsx',...
%     'Sheet','AveragedData',...
%     'Range','C2:W5'); 

ControlHem.Data(1).LVWeight = 81.87; %LVWeight; 

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
ControlHem.Data(i).PLVmin   = [0]; %PointValues(i,7); 
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



