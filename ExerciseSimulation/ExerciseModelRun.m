clear;clc;close all;

addpath('../SRC_Perfusion');
addpath('../SRC_RepVessel');

if exist('Data_Ready','var')==1
else
    
    ReadDataParams;
    
end


[Rest, Exercise] = ExerciseModelEvalFun(xendo, xmid, xepi, Control, MetSignal);