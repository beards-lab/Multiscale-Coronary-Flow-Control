function data = dataprocessing(Control)

LVWeight = Control.LVWeight; 
scale = 100 / LVWeight; 

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
data.LVWeight = LVWeight; 
data.scale    = scale; 

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

end 
