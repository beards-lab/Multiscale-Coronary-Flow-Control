function [f,outputs] = dXdT_myocardium(t,X,measurements,Params,flag)

%% DATA INPUT

P_in = measurements.AoPspl(t);
P_LV = measurements.PLVspl(t);
dPdT = measurements.dPLVdtspl(t);

P_im1 = 1.2*0.167*P_LV;
P_im2 = 1.2*0.500*P_LV;
P_im3 = 1.2*0.833*P_LV;

dPim1_dt = 1.2*0.167*dPdT;
dPim2_dt = 1.2*0.500*dPdT;
dPim3_dt = 1.2*0.833*dPdT;

P_RA = 0; % right atrial pressure (mmHg)

%% PARAMETERS 
x = 1; 
C_PA  = x * Params.C_PA; % mL / mmHg * .1
L_PA  = Params.L_PA; % mmHg / (mL sec)
R_PA  = Params.R_PA; % mmHg / (mL / sec) *** * 20
R_PV  = Params.R_PV; % mmHg / (mL / sec)
C_PV  = Params.C_PV; % mL / mmHg
R0m   = 3 * Params.R0m;  % mmHg / (mL / sec)
R01   = Params.R01; % mmHg / (mL / sec)
R02   = Params.R02; % mmHg / (mL / sec)
V01   = Params.V01; % mL
Vc    = .2*Params.Vc;  % mL
V02   = Params.V02; % mL
C11   = x * Params.C11; % mL / mmHg ***
C12   = x * Params.C12; % mL / mmHg ***
C13   = x * Params.C13; % mL / mmHg ***
C2    = x * Params.C2; % mL / mmHg
gamma = Params.gamma; 
cf1   = Params.cf1; % epi/endo compliance factor
rf1   = Params.rf1; % epi/endo resistance factor
cf2   = Params.cf2; % epi/mid compliance factor
rf2   = Params.rf2; % epi/mid resistance factor

%% STATE VARIABLES

P_PA = X(1); % penetrating artery pressure
Q_PA = X(2); % inlet flow penetrating artery
P11  = X(3); 
P21  = X(4);
P12  = X(5); 
P22  = X(6);
P13  = X(7); 
P23  = X(8);
P_PV = X(9); % penetrating vein pressure

%% CALCULATIONS 

V11 = max(cf1*((P11 - P_im1)*C11+V01), Vc);

V21 = cf1*((P21 - P_im1)*C2+V02);
R11 = rf1*R01*(V01/V11).^2;
R21 = rf1*R02*(V02/V21).^2;
Rm1 = R0m*(gamma*R11/R01 + (1-gamma)*R21/R02);
Q11 = (P_PA - P11)/R11;
Qm1 = (P11 - P21)/Rm1;
% Q21 = (P21 - P_PV)/R21;

V12 = max(cf2*((P12 - P_im2)*C12+V01), Vc);
V22 = cf2*((P22 - P_im2)*C2+V02);
R12 = rf2*R01*(V01/V12).^2;
R22 = rf2*R02*(V02/V22).^2;
Rm2 = R0m*(gamma*R12/R01 + (1-gamma)*R22/R02);
Q12 = (P_PA - P12)/R12;
Qm2 = (P12 - P22)/Rm2;
% Q22 = (P22 - P_PV)/R22;

V13 = max((P13 - P_im3)*C13+V01, Vc);
V23 = (P23 - P_im3)*C2+V02;
R13 = R01*(V01/V13).^2;
R23 = R02*(V02/V23).^2;
Rm3 = R0m*(gamma*R13/R01 + (1-gamma)*R23/R02);
Q13 = (P_PA - P13)/R13;
Qm3 = (P13 - P23)/Rm3;
% Q23 = (P23 - P_PV)/R23;

A1 = [(R21+R_PV/2), (R_PV/2), (R_PV/2)];
A2 = [(R_PV/2), (R22+R_PV/2), (R_PV/2)];
A3 = [(R_PV/2), (R_PV/2), (R23+R_PV/2)];

A = [A1;A2;A3];
B = [P21-P_PV; P22-P_PV; P23-P_PV];

X = A\B;

Q21 = double(X(1));
Q22 = double(X(2));
Q23 = double(X(3));

Q21 = max(Q21,0);
Q22 = max(Q22,0);
Q23 = max(Q23,0);


Q_ima = Q11 + Q12 + Q13;
Q_imv = Q21 + Q22 + Q23;

Q_out = (P_PV - P_RA)/(R_PV/2); 

f(1,:) = (Q_PA - Q_ima)/C_PA; % P_PA
f(2,:) = (P_in - P_PA - Q_PA*R_PA)/L_PA; % Q_PA
f(3,:) = (Q11-Qm1)/(cf1*C11) + dPim1_dt; % P11
f(4,:) = (Qm1-Q21)/(cf1*C2) + dPim1_dt; % P21
f(5,:) = (Q12-Qm2)/(cf2*C12) + dPim2_dt; % P12
f(6,:) = (Qm2-Q22)/(cf2*C2) + dPim2_dt; % P22
f(7,:) = (Q13-Qm3)/(C13) + dPim3_dt; % P13
f(8,:) = (Qm3-Q23)/(C2) + dPim3_dt; % P23
f(9,:) = (Q_imv - Q_out)/C_PV; % P_PV

if flag == 0 
    outputs = []; 
else 
    outputs = [V11; V21; R11; R21; Rm1; Q11; Qm1; 
    V12; V22; R12; R22; Rm2;Q12; Qm2; 
    V13; V23; R13; R23; Rm3; Q13; Qm3; 
    Q21; Q22; Q23; Q_ima; Q_imv; Q_out]; 
end 
    
