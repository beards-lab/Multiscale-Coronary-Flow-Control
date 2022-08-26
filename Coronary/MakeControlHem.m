
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

AoP_B  = M_Base(:,1); 
AoP_H1 = M_Hem1(:,1); 
AoP_H2 = M_Hem2(:,1); 
AoP_H3 = M_Hem3(:,1); 

Flow_B = M_Base(:,2); 
Flow_H1 = M_Hem1(:,2); 
Flow_H2 = M_Hem2(:,2); 
Flow_H3 = M_Hem3(:,2); 

PLV_B = M_Base(:,3); 
PLV_H1 = M_Hem1(:,3); 
PLV_H2 = M_Hem2(:,3); 
PLV_H3 = M_Hem3(:,3); 

%% Find mean of flows 

MeanFlow_B  = mean(Flow_B); 
MeanFlow_H1 = mean(Flow_H1); 
MeanFlow_H2 = mean(Flow_H2); 
MeanFlow_H3 = mean(Flow_H3); 

%% Smooth out PLV 

PLV_B  = smoothdata(PLV_B,'gaussian','smoothingfactor',0.015); %smoothing makes the numerics easier
PLV_H1 = smoothdata(PLV_H1,'gaussian','smoothingfactor',0.015); %smoothing makes the numerics easier
PLV_H2 = smoothdata(PLV_H2,'gaussian','smoothingfactor',0.015); %smoothing makes the numerics easier
PLV_H3 = smoothdata(PLV_H3,'gaussian','smoothingfactor',0.015); %smoothing makes the numerics easier

%% Make Pressure Derivatives 

dPLV_Bdt  = diff(PLV_B)/dt; 
dPLV_H1dt = diff(PLV_H1)/dt; 
dPLV_H2dt = diff(PLV_H2)/dt; 
dPLV_H3dt = diff(PLV_H3)/dt; 

dPLV_Bdt  = [dPLV_Bdt(1);  dPLV_Bdt]; %Repeat the first term 
dPLV_H1dt = [dPLV_H1dt(1); dPLV_H1dt]; %Repeat the first term 
dPLV_H2dt = [dPLV_H2dt(1); dPLV_H2dt]; %Repeat the first term 
dPLV_H3dt = [dPLV_H3dt(1); dPLV_H3dt]; %Repeat the first term 

%% Make interpolants

AoPspl_B  = griddedInterpolant(Time,AoP_B); 
AoPspl_H1 = griddedInterpolant(Time,AoP_H1); 
AoPspl_H2 = griddedInterpolant(Time,AoP_H2); 
AoPspl_H3 = griddedInterpolant(Time,AoP_H3); 

PLVspl_B  = griddedInterpolant(Time,PLV_B); 
PLVspl_H1 = griddedInterpolant(Time,PLV_H1); 
PLVspl_H2 = griddedInterpolant(Time,PLV_H2); 
PLVspl_H3 = griddedInterpolant(Time,PLV_H3); 

dPLV_Bdtspl  = griddedInterpolant(Time,dPLV_Bdt); 
dPLV_H1dtspl = griddedInterpolant(Time,dPLV_H1dt); 
dPLV_H2dtspl = griddedInterpolant(Time,dPLV_H2dt); 
dPLV_H3dtspl = griddedInterpolant(Time,dPLV_H3dt); 

%% Make data structure 

ControlHem.Data(1).Time      = Time; 
ControlHem.Data(1).dt        = dt; 
ControlHem.Data(1).AoP       = AoP_B; 
ControlHem.Data(1).Flow      = Flow_B; 
ControlHem.Data(1).MeanFlow  = MeanFlow_B; 
ControlHem.Data(1).PLV       = PLV_B; 
ControlHem.Data(1).dPLVdt    = dPLV_Bdt; 
ControlHem.Data(1).AoPspl    = AoPspl_B; 
ControlHem.Data(1).PLVspl    = PLVspl_B; 
ControlHem.Data(1).dPLVdtspl = dPLV_Bdtspl; 

ControlHem.Data(2).Time      = Time; 
ControlHem.Data(2).dt        = dt; 
ControlHem.Data(2).AoP       = AoP_H1; 
ControlHem.Data(2).Flow      = Flow_H1; 
ControlHem.Data(2).MeanFlow  = MeanFlow_H1; 
ControlHem.Data(2).PLV       = PLV_H1; 
ControlHem.Data(2).dPLVdt    = dPLV_H1dt; 
ControlHem.Data(2).AoPspl    = AoPspl_H1; 
ControlHem.Data(2).PLVspl    = PLVspl_H1; 
ControlHem.Data(2).dPLVdtspl = dPLV_H1dtspl; 

ControlHem.Data(3).Time      = Time; 
ControlHem.Data(3).dt        = dt; 
ControlHem.Data(3).AoP       = AoP_H2; 
ControlHem.Data(3).Flow      = Flow_H2; 
ControlHem.Data(3).MeanFlow  = MeanFlow_H2;  
ControlHem.Data(3).PLV       = PLV_H2; 
ControlHem.Data(3).dPLVdt    = dPLV_H2dt; 
ControlHem.Data(3).AoPspl    = AoPspl_H2; 
ControlHem.Data(3).PLVspl    = PLVspl_H2; 
ControlHem.Data(3).dPLVdtspl = dPLV_H2dtspl; 

ControlHem.Data(4).Time      = Time; 
ControlHem.Data(4).dt        = dt; 
ControlHem.Data(4).AoP       = AoP_H3; 
ControlHem.Data(4).Flow      = Flow_H3; 
ControlHem.Data(4).MeanFlow  = MeanFlow_H3; 
ControlHem.Data(4).PLV       = PLV_H3; 
ControlHem.Data(4).dPLVdt    = dPLV_H3dt; 
ControlHem.Data(4).AoPspl    = AoPspl_H3; 
ControlHem.Data(4).PLVspl    = PLVspl_H3; 
ControlHem.Data(4).dPLVdtspl = dPLV_H3dtspl; 

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
    ControlHem.Data(i).PLVmin   = PointValues(i,7); 
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

MBP = (1/3) * SBP + (2/3) * DBP



