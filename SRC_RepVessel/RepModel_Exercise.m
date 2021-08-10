function [DE, ActE, S_myo, S_meta, S_HR] = RepModel_Exercise(State, Control, layer, x, MetSignal)
% This function pertains to the representative vessel model. The inputs of
% this function are
% State : Rest/Exercise
% Control : Initial and blood O2 data
% layer : subendo./midwall/subepi.
% x : Parameters for each layer xendo/xmid/xepi
% MetSignal : Metabolic signal, top performing considered here: QM

st = 'normal'; %% This corresponds to fully active, passive, and noraml 
% (vessel with vasoreactivity states).In the exercise simulations, st is
% always normal.

% Simulation preparation
switch MetSignal
    
    case 'ATP'
        
        S0 = x(13);
        
    otherwise
        
        S0 = 0.037; %% will not be used for other MetSignal models
        
end

% Calculate the metabolic signal for the simulation state (rest/exercise)
State = MetabolicSignalCalc_Exercise(State, S0, MetSignal);

%% The pressure and metabolic signal is read to be used in the rep. vesel model, diameter will change.

eval(['State.Dexp = State.',layer,'.D;']);
eval(['State.Ptm = State.',layer,'.Ptm;']);
eval(['MetSignalC = State.',layer,'.MetSignal;']);

eval(['Control.Dexp = Control.',layer,'.D(4);']);
eval(['Control.Ptm = Control.',layer,'.Ptm(4);']);
Dc = Control.Dexp;
Pc = Control.Ptm;

% Run the representative vessel model:
[DE, ActE, S_myo, S_meta, S_HR] = CarlsonModelTime(x, State.Ptm, State.Dexp, MetSignalC, State.HR, Dc, Pc, st);

end
