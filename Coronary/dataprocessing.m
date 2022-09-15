function data = dataprocessing(data)


%% Determine scaling factor by LV weight 

LVWeight = data.LVWeight; 
scale    = 100 / LVWeight; 

%% Unpack data structure 

% Load time vector and heart rate/period 
t  = data.Time; 
dt = data.dt; 

% Load heart period and rate 
T  = data.T; 
HR = data.HR; 

% Load time series 
P_Ao    = data.P_Ao; 
P_LV    = data.P_LV; 
Flow    = data.Flow / 60 * scale; 
dP_LVdt = data.dP_LVdt; 

%% Calculate max, min and average values 

% LV pressure 
M_P_LV = max(P_LV); 
m_P_LV = min(P_LV); 
[~,locs_M] = findpeaks(P_LV,'MinPeakProminence',.5*(M_P_LV - m_P_LV)); 
[~,locs_m] = findpeaks(-P_LV,'MinPeakProminence',.5*(M_P_LV - m_P_LV)); 

P_LV_M = mean(P_LV(locs_M)); 
P_LV_m = mean(P_LV(locs_m)); 
P_LVbar = trapz(t(locs_m(2):locs_m(end-1)),P_LV(locs_m(2):locs_m(end-1))) / (t(locs_m(end-1)) - t(locs_m(2))); 

% Aortic pressure 
M_P_Ao = max(P_Ao); 
m_P_Ao = min(P_Ao); 
[~,locs_M] = findpeaks(P_Ao,'MinPeakProminence',.5*(M_P_Ao - m_P_Ao)); 
[~,locs_m] = findpeaks(-P_Ao,'MinPeakProminence',.5*(M_P_Ao - m_P_Ao)); 

P_Ao_M = mean(P_Ao(locs_M)); 
P_Ao_m = mean(P_Ao(locs_m)); 
P_Aobar = trapz(t(locs_m(2):locs_m(end-1)),P_Ao(locs_m(2):locs_m(end-1))) / (t(locs_m(end-1)) - t(locs_m(2))); 

% Flow 
M_Flow = max(Flow); 
m_Flow = min(Flow); 
[~,locs_M] = findpeaks(Flow,'MinPeakProminence',.5*(M_Flow - m_Flow)); 
[~,locs_m] = findpeaks(-Flow,'MinPeakProminence',.5*(M_Flow - m_Flow)); 

Flow_M = mean(Flow(locs_M)); 
Flow_m = mean(Flow(locs_m)); 
Flowbar = trapz(t(locs_m(2):locs_m(end-1)),Flow(locs_m(2):locs_m(end-1))) / (t(locs_m(end-1)) - t(locs_m(2)));

% Find time points when P_LV is in diastole 
M_dP_LVdt = max(dP_LVdt); 
m_dP_LVdt = min(dP_LVdt); 
[~,locs_M] = findpeaks(dP_LVdt,'MinPeakProminence',.5*(M_dP_LVdt - m_dP_LVdt)); 
[~,locs_m] = findpeaks(-dP_LVdt,'MinPeakProminence',.5*(M_dP_LVdt - m_dP_LVdt)); 

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

%% Construct data structure output

data.t        = t; 
data.dt       = dt; 
data.T        = T; 
data.HR       = HR; 
data.P_Ao     = P_Ao; 
data.PLV      = P_LV; 
data.Flow     = Flow; 
data.dPLVdt   = dP_LVdt; 
data.LVWeight = LVWeight; 
data.scale    = scale; 

% Load interpolants 
data.P_Aospl    = data.P_Aospl; 
data.P_LVspl    = data.P_LVspl; 
data.dP_LVdtspl = data.dP_LVdtspl; 

data.P_LV_M    = P_LV_M; 
data.P_LV_m    = P_LV_m; 
data.P_LVbar   = P_LVbar; 
data.P_Ao_M    = P_Ao_M; 
data.P_Ao_m    = P_Ao_m; 
data.P_Aobar   = P_Aobar; 
data.Flow_M    = Flow_M; 
data.Flow_m    = Flow_m; 
data.Flowbar   = Flowbar; 
data.Flow_base = Flow_base; 

% Load blood gas measurements 
data.ArtO2Cnt   = data.ArtO2Cnt;
data.CVO2Cnt    = data.CVO2Cnt;
data.ArtPO2     = data.ArtPO2;
data.CvPO2      = data.CVPO2;
data.ArtO2Sat   = data.ArtO2Sat;
data.CvO2Sat    = data.CVO2Sat;
data.Hgb        = data.Hgb;
data.HCT        = data.HCT;
data.VisRatio   = data.VisRatio;

end 
