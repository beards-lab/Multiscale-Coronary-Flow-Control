%% Reads Pig C pzf simulation results from file as an initialization
load ControlPigC.mat

%% Initialization of blood gas measurements and rep. vessel model based on Pig C
BloodGasMeasurementReading;

Control =   Calculations(Control);
Control = RepVessel(Control);



%% What is the Metabolic Signal?

MetOptions = {'QM','ATP','VariableSV','Generic','MVO2','QdS','Q','M2'};
MetSignal = MetOptions{1};

%% Read the estimated rep. vessel model parameters
    
fileID = 'Params.txt';
fid = fopen(fileID,'rt');
tline1 = fgets(fid);
tline2 = fgets(fid);
tline3 = fgets(fid);

eval(tline1);eval(tline2);eval(tline3);

fclose('all');


