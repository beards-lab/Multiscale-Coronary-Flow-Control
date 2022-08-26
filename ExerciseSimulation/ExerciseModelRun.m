clear;%close all;
% This is the main script for running the exercise simulations. Two paths
% are added to include source files for lumped myocardial circulation model
% and the representative vessel model. The corresponding functions for each
% model is located in these folders
addpath('../SRC_Perfusion'); % Path for myocardial circulation model
addpath('../SRC_RepVessel'); % Path for representative vessel model

%% Read blood gas measurement data for initialization and parameters for the simulation
ReadDataParams;
    
%% Runs the coupled model for rest and exercise
[Rest, Exercise] = ExerciseModelEvalFun(xendo, xmid, xepi, Control, MetSignal);