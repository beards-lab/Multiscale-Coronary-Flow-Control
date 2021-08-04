%% Data from Kiel et al. read and assiged in MATLAB


CPP = [40 ,60, 80, 100, 120, 140];

BloodGasMeasurementsControl = [
13.6	7.2	144	27	100	51.7	10.2	30;											
13.6	5.2	144	20	100	38.5	10.1	30;											
13.7	3.6	150	19	100	27.8	9.7     31.5;											
13.7	3.5	150	16	100	25.4	10.1	31;											
13.1	2.7	154	14	100	19.3	10      30.5;											
14      1.3	154	8	100	9.2     10      30.5;
];


Control.LVweight = 81.87;

% Viscosity function from Snyder 1971 - Influence of temperature and hematocriton blood viscosity 
k0 = 0.0322;
k3 = 1.08*1e-4;
k2 = 0.02;
T = 37 ;
Viscosity = @(x) 2.03 * exp( (k0 - k3*T)*x - k2*T );
% VisCorrection = @(x) 14.5583*x.^3 + 3.0897*x.^2 + 3.4796*x + 1.0000; % Curve fitted to curve in Fig. 7 of Pries et al paper.

for j = 1:length(CPP)
    
    Control.ArtO2Cnt(j) =   BloodGasMeasurementsControl(6-j+1,1);
    Control.CVO2Cnt(j)  =   BloodGasMeasurementsControl(6-j+1,2);
    Control.ArtPO2(j)   =   BloodGasMeasurementsControl(6-j+1,3);
    Control.CvPO2(j)    =   BloodGasMeasurementsControl(6-j+1,4);
    Control.ArtO2Sat(j) =   BloodGasMeasurementsControl(6-j+1,5);
    Control.CvO2Sat(j)  =   BloodGasMeasurementsControl(6-j+1,6);
    Control.Hgb(j)      =   BloodGasMeasurementsControl(6-j+1,7);
    Control.HCT(j)      =   BloodGasMeasurementsControl(6-j+1,8);
        
end


Control.Vis = Viscosity(Control.HCT);

Control.VisRatio = Control.Vis./Control.Vis(4);



