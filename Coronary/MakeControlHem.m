
clear all
close all

%% Time Series Data 
% Choose first point to start in end diastole. Last point is the end of the
% data for the shortest data set 

Time = readmatrix('06092021_Control_Hemorrhage_OSS1150.xlsx', ...
    'Sheet','PhasicTracing',...
    'Range','A9:A6019');

M_Base = readmatrix('06092021_Control_Hemorrhage_OSS1150.xlsx', ...
    'Sheet','PhasicTracing',...
    'Range','C9:E6019');

M_Hem1 = readmatrix('06092021_Control_Hemorrhage_OSS1150.xlsx', ...
    'Sheet','PhasicTracing',...
    'Range','I9:K6019');

M_Hem2 = readmatrix('06092021_Control_Hemorrhage_OSS1150.xlsx', ...
    'Sheet','PhasicTracing',...
    'Range','N9:P6019');

M_Hem3 = readmatrix('06092021_Control_Hemorrhage_OSS1150.xlsx', ...
    'Sheet','PhasicTracing',...
    'Range','S9:U6019');

Time = Time - Time(1); 
dt = mean(diff(Time)); 

%% Extract data 

P_Ao_B  = M_Base(:,1); 
P_Ao_H1 = M_Hem1(:,1); 
P_Ao_H2 = M_Hem2(:,1); 
P_Ao_H3 = M_Hem3(:,1); 

Flow_B = M_Base(:,2); 
Flow_H1 = M_Hem1(:,2); 
Flow_H2 = M_Hem2(:,2); 
Flow_H3 = M_Hem3(:,2); 

P_LV_B = M_Base(:,3); 
P_LV_H1 = M_Hem1(:,3); 
P_LV_H2 = M_Hem2(:,3); 
P_LV_H3 = M_Hem3(:,3); 

%% Find mean of flows 

MeanFlow_B  = mean(Flow_B); 
MeanFlow_H1 = mean(Flow_H1); 
MeanFlow_H2 = mean(Flow_H2); 
MeanFlow_H3 = mean(Flow_H3); 

%% Smooth out PLV 

P_LV_B  = smoothdata(P_LV_B,'gaussian','smoothingfactor',0.015); %smoothing makes the numerics easier
P_LV_H1 = smoothdata(P_LV_H1,'gaussian','smoothingfactor',0.015); %smoothing makes the numerics easier
P_LV_H2 = smoothdata(P_LV_H2,'gaussian','smoothingfactor',0.015); %smoothing makes the numerics easier
P_LV_H3 = smoothdata(P_LV_H3,'gaussian','smoothingfactor',0.015); %smoothing makes the numerics easier

%% Make Pressure Derivatives 

dP_LV_Bdt  = diff(P_LV_B)/dt; 
dP_LV_H1dt = diff(P_LV_H1)/dt; 
dP_LV_H2dt = diff(P_LV_H2)/dt; 
dP_LV_H3dt = diff(P_LV_H3)/dt; 

dP_LV_Bdt  = [dP_LV_Bdt(1);  dP_LV_Bdt]; %Repeat the first term 
dP_LV_H1dt = [dP_LV_H1dt(1); dP_LV_H1dt]; %Repeat the first term 
dP_LV_H2dt = [dP_LV_H2dt(1); dP_LV_H2dt]; %Repeat the first term 
dP_LV_H3dt = [dP_LV_H3dt(1); dP_LV_H3dt]; %Repeat the first term 

%% Make interpolants

P_Aospl_B  = griddedInterpolant(Time,P_Ao_B); 
P_Aospl_H1 = griddedInterpolant(Time,P_Ao_H1); 
P_Aospl_H2 = griddedInterpolant(Time,P_Ao_H2); 
P_Aospl_H3 = griddedInterpolant(Time,P_Ao_H3); 

P_LVspl_B  = griddedInterpolant(Time,P_LV_B); 
P_LVspl_H1 = griddedInterpolant(Time,P_LV_H1); 
P_LVspl_H2 = griddedInterpolant(Time,P_LV_H2); 
P_LVspl_H3 = griddedInterpolant(Time,P_LV_H3); 

dP_LV_Bdtspl  = griddedInterpolant(Time,dP_LV_Bdt); 
dP_LV_H1dtspl = griddedInterpolant(Time,dP_LV_H1dt); 
dP_LV_H2dtspl = griddedInterpolant(Time,dP_LV_H2dt); 
dP_LV_H3dtspl = griddedInterpolant(Time,dP_LV_H3dt); 

%% Make data structure 

ControlHem.Data(1).Time       = Time; 
ControlHem.Data(1).dt         = dt; 
ControlHem.Data(1).P_Ao       = P_Ao_B; 
ControlHem.Data(1).Flow       = Flow_B; 
ControlHem.Data(1).MeanFlow   = MeanFlow_B; 
ControlHem.Data(1).P_LV       = P_LV_B; 
ControlHem.Data(1).dP_LVdt    = dP_LV_Bdt; 
ControlHem.Data(1).P_Aospl    = P_Aospl_B; 
ControlHem.Data(1).P_LVspl    = P_LVspl_B; 
ControlHem.Data(1).dP_LVdtspl = dP_LV_Bdtspl; 

ControlHem.Data(2).Time       = Time; 
ControlHem.Data(2).dt         = dt; 
ControlHem.Data(2).P_Ao       = P_Ao_H1; 
ControlHem.Data(2).Flow       = Flow_H1; 
ControlHem.Data(2).MeanFlow   = MeanFlow_H1; 
ControlHem.Data(2).P_LV       = P_LV_H1; 
ControlHem.Data(2).dP_LVdt    = dP_LV_H1dt; 
ControlHem.Data(2).P_Aospl    = P_Aospl_H1; 
ControlHem.Data(2).P_LVspl    = P_LVspl_H1; 
ControlHem.Data(2).dP_LVdtspl = dP_LV_H1dtspl; 

ControlHem.Data(3).Time       = Time; 
ControlHem.Data(3).dt         = dt; 
ControlHem.Data(3).P_Ao       = P_Ao_H2; 
ControlHem.Data(3).Flow       = Flow_H2; 
ControlHem.Data(3).MeanFlow   = MeanFlow_H2;  
ControlHem.Data(3).P_LV       = P_LV_H2; 
ControlHem.Data(3).dP_LVdt    = dP_LV_H2dt; 
ControlHem.Data(3).P_Aospl    = P_Aospl_H2; 
ControlHem.Data(3).P_LVspl    = P_LVspl_H2; 
ControlHem.Data(3).dP_LVdtspl = dP_LV_H2dtspl; 

ControlHem.Data(4).Time       = Time; 
ControlHem.Data(4).dt         = dt; 
ControlHem.Data(4).P_Ao       = P_Ao_H3; 
ControlHem.Data(4).Flow       = Flow_H3; 
ControlHem.Data(4).MeanFlow   = MeanFlow_H3; 
ControlHem.Data(4).P_LV       = P_LV_H3; 
ControlHem.Data(4).dP_LVdt    = dP_LV_H3dt; 
ControlHem.Data(4).P_Aospl    = P_Aospl_H3; 
ControlHem.Data(4).P_LVspl    = P_LVspl_H3; 
ControlHem.Data(4).dP_LVdtspl = dP_LV_H3dtspl; 

%% Point values
 
LVWeight = readmatrix('06092021_Control_Hemorrhage_OSS1150.xlsx',...
    'Sheet','AveragedData',...
    'Range','B2:B2'); 

PointValues = readmatrix('06092021_Control_Hemorrhage_OSS1150.xlsx',...
    'Sheet','AveragedData',...
    'Range','C2:W5'); 


% Viscosity function from Snyder 1971 - Influence of temperature and hematocriton blood viscosity 
k0 = 0.0322;
k3 = 1.08*1e-4;
k2 = 0.02;
T = 37 ;
Viscosity = @(x) 2.03 * exp( (k0 - k3*T)*x - k2*T );

for i = 1:length(PointValues(:,1)) 
    ControlHem.Data(i).SBP      = PointValues(i,1); % Systolic blood pressure
    ControlHem.Data(i).DBP      = PointValues(i,2); % Diastolic blood pressure
    ControlHem.Data(i).MBP      = PointValues(i,3); % Mean blood pressure 
    ControlHem.Data(i).HR       = PointValues(i,4); % Heart rate 
    ControlHem.Data(i).T        = 60 / ControlHem.Data(i).HR; % Heart period
    ControlHem.Data(i).CorFlow  = PointValues(i,5); 
    ControlHem.Data(i).P_LVmin  = PointValues(i,7); 
    ControlHem.Data(i).dPdtmax  = PointValues(i,8);
    ControlHem.Data(i).dPdtmin  = PointValues(i,9); 
    ControlHem.Data(i).tauhalf  = PointValues(i,10);
    ControlHem.Data(i).ArtO2Cnt = PointValues(i,11); 
    ControlHem.Data(i).CVO2Cnt  = PointValues(i,12);
    ControlHem.Data(i).ArtPO2   = PointValues(i,13); 
    ControlHem.Data(i).CVPO2    = PointValues(i,14);
    ControlHem.Data(i).ArtO2Sat = PointValues(i,15); 
    ControlHem.Data(i).CVO2Sat  = PointValues(i,16);
    ControlHem.Data(i).Hgb      = PointValues(i,17); 
    ControlHem.Data(i).HCT      = PointValues(i,18);
    ControlHem.Data(i).Vis      = Viscosity(PointValues(i,18)); 
    ControlHem.Data(i).VisRatio = Viscosity(PointValues(i,18))/Viscosity(PointValues(1,18)); 
    ControlHem.Data(i).LAD_Epi  = PointValues(i,19); 
    ControlHem.Data(i).LAD_Mid  = PointValues(i,20);
    ControlHem.Data(i).LAD_Endo = PointValues(i,21); 
    ControlHem.Data(i).LVWeight = LVWeight; 

end 

save ControlHem_OSS1150.mat ControlHem

