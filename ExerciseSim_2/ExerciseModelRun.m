clear
%close all

% This is the main script for running the exercise simulations. Two paths
% are added to include source files for lumped myocardial circulation model
% and the representative vessel model. The corresponding functions for each
% model is located in these folders
addpath('SRC_Perfusion'); % Path for myocardial circulation model
addpath('SRC_RepVessel'); % Path for representative vessel model

%% Reads Pig C pzf simulation results from file as an initialization
%load ../ExerciseSimulation/ControlPigC.mat

%load ../ExerciseSimulation_Hem/ControlHamidPaper.mat ControlHem
load ../ExerciseSimulation_Hem/ControlHem_OSS1150.mat ControlHem

k = 1; % Control 
Control = ControlHem.Data(k); 

%% What is the Metabolic Signal? The top ranking model is chosen here: QM

MetOptions = {'QM','ATP','VariableSV','Generic','MVO2','QdS','Q','M2'};
MetSignal = MetOptions{1};

%% Read the estimated rep. vessel model parameters
fileID = '../ExerciseSimulation/Params.txt';
fid = fopen(fileID,'rt');
tline1 = fgets(fid);
tline2 = fgets(fid);
tline3 = fgets(fid);
eval(tline1);eval(tline2);eval(tline3);
fclose('all');

%% Runs the coupled model for rest and exercise
Rest = ExerciseModelEvalFun(xendo, xmid, xepi, Control, MetSignal);