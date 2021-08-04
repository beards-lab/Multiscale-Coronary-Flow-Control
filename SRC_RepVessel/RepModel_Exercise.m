function [DE, ActE, S_myo, S_meta, S_HR] = RepModel_Exercise(State, Control, layer, x, MetSignal)

state = 'normal';
%%%%%%%%%%%%%% Preparation
switch MetSignal
    
    case 'ATP'
        
        S0 = x(13);
        
    otherwise
        
        S0 = 0.037;
        
end

State = MetabolicSignalCalc_Exercise(State, S0, MetSignal);

%%%%%%%%%%%%%% Control

eval(['State.Dexp = State.',layer,'.D;']);
eval(['State.Ptm = State.',layer,'.Ptm;']);
eval(['MetSignalC = State.',layer,'.MetSignal;']);

eval(['Control.Dexp = Control.',layer,'.D(4);']);
eval(['Control.Ptm = Control.',layer,'.Ptm(4);']);
Dc = Control.Dexp;
Pc = Control.Ptm;

[DE, ActE, S_myo, S_meta, S_HR] = CarlsonModelTime(x, State.Ptm, State.Dexp, MetSignalC, State.HR, Dc, Pc, state);

end
