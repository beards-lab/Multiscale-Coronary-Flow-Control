function Init = initialconditions(data)


%% Set initial conditions 

P_PA_0   = data.P_Ao(1); 
Q_PA_0   = data.Q_myo(1); 
Pa_epi_0 = data.P_Ao(1) * (50  / 120); 
Pa_mid_0 = data.P_Ao(1) * (85  / 120); 
Pa_end_0 = data.P_Ao(1) * (115 / 120); 
Pv_epi_0 = data.P_Ao(1) * (50  / 120); 
Pv_mid_0 = data.P_Ao(1) * (85  / 120); 
Pv_end_0 = data.P_Ao(1) * (115 / 120);
P_PV_0   = 5;

%% Outputs 

Init = [P_PA_0; Q_PA_0; 
    Pa_epi_0; Pa_mid_0; Pa_end_0; 
    Pv_epi_0; Pv_mid_0; Pv_end_0;
    P_PV_0; 
    ];

end 


