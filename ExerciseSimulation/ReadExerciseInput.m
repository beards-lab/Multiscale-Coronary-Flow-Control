function [tdata,AoP,PLV,Flow,MeanFlow] = ReadExerciseInput(data)
% This function processes the experimental data, pressures (aortic and LV) and
% LAD flow. 
dt    = 1/500;
AoP   = data(:,2);
PLV   = 0.85*(data(:,3)-17);
PLV   = smoothdata(PLV,'gaussian','smoothingfactor',0.015); %smoothing makes the numerics easier
Flow = data(:,1);
MeanFlow = mean(Flow);
tdata = (0:(length(AoP)-1)).*dt;


end