function State = MetabolicSignalCalc_Exercise(State, So, MetSignal)
% This function calculates the metabolic signal for the rest/exercise
% simulation cases. The inputs are:
% State = Rest/Exercise
% So = ATP release parameter, will not be used for MetSignal models other
% than ATP-dependent.
% MetSignal : Metabolic signal, top performing considered here: QM
% Output is State structure which includes the metabolic signal mag.

[Q_endo, Q_mid, Q_epi] = CycleAvg_Exercise(State, 'Q1');

R_MVO2 = 1.5; % Endo to Epi MVO2 ratio
% Extra parameters for ATP-dependent model (Pradhan et al. 2016)
Vc = 0.04;
J0 = 283.388e3;
Ta = 28.151;
C0 = 476;

q_endo = Q_endo*60 / (State.LVweight); % the last 1/3 is roughly for subendo layer
q_mid = Q_mid*60 / (State.LVweight); % the last 1/3 is roughly for mid layer
q_epi = Q_epi*60 / (State.LVweight); % the last 1/3 is roughly for subepi layer

Ht = State.HCT/100; % Hematocrit

Sa = State.ArtO2Sat/100; % Arterial O2 sat.
Sv = State.CvO2Sat/100;  % Venous 2 sat.

State.Mtotal = State.Exercise_LvL*State.MVO2;

% divide the Mtotal to layers
Mendo = R_MVO2/(3/2*(R_MVO2+1));
Mmid  = ((R_MVO2+1)/2)/(3/2*(R_MVO2+1));
Mepi  = 1/(3/2*(R_MVO2+1));

State.endo.MVO2 = State.Mtotal*Mendo;
State.mid.MVO2 = State.Mtotal*Mmid;
State.epi.MVO2 = State.Mtotal*Mepi;

% Fund the venous ATP concentration
State.endo.Tv = Vc*Ht*J0*So/(q_endo*(Sa-Sv)) * exp(-Sa/So) * ( exp( (Sa-Sv)/So ) - 1) + Ta;
State.mid.Tv  = Vc*Ht*J0*So/(q_mid*(Sa-Sv)) * exp(-Sa/So) * ( exp( (Sa-Sv)/So ) - 1) + Ta;
State.epi.Tv  = Vc*Ht*J0*So/(q_epi*(Sa-Sv)) * exp(-Sa/So) * ( exp( (Sa-Sv)/So ) - 1) + Ta;

State.endo.dS = Sv;
State.mid.dS  = Sv;
State.epi.dS  = Sv;

State.endo.Sv = Sa - State.endo.MVO2/(C0*Ht*q_endo);
State.mid.Sv  = Sa - State.mid.MVO2/(C0*Ht*q_mid);
State.epi.Sv  = Sa - State.epi.MVO2/(C0*Ht*q_epi);

switch MetSignal
    case 'QM'
        
        State.endo.MetSignal = State.endo.MVO2*q_endo;
        State.mid.MetSignal = State.mid.MVO2*q_mid;
        State.epi.MetSignal = State.epi.MVO2*q_epi;
        
    case 'ATP'
        
        State.endo.MetSignal = State.endo.Tv;
        State.mid.MetSignal  = State.mid.Tv;
        State.epi.MetSignal  = State.epi.Tv;
        
    case 'VariableSV'
        
        State.endo.MetSignal = max(State.endo.Sv,0);
        State.mid.MetSignal  = max(State.mid.Sv,0);
        State.epi.MetSignal  = max(State.epi.Sv,0);
        
    case 'Generic'
        
        State.endo.MetSignal = State.endo.dS;
        State.mid.MetSignal  = State.mid.dS;
        State.epi.MetSignal  = State.epi.dS;
        
    case 'MVO2'
        
        State.endo.MetSignal = State.endo.MVO2;
        State.mid.MetSignal = State.mid.MVO2;
        State.epi.MetSignal = State.epi.MVO2;
        
    case 'QdS'
        
        State.endo.MetSignal = q_endo*(Sa-Sv);
        State.mid.MetSignal = q_mid*(Sa-Sv);
        State.epi.MetSignal = q_epi*(Sa-Sv);
        
    case 'Q'
        
        State.endo.MetSignal = q_endo;
        State.mid.MetSignal = q_mid;
        State.epi.MetSignal = q_epi;
        
    case 'M2'
        
        State.endo.MetSignal = State.endo.MVO2^2;
        State.mid.MetSignal = State.mid.MVO2^2;
        State.epi.MetSignal = State.epi.MVO2^2;
        
end

return
