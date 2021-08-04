function Control = RepVessel(Control)

CPP = [40, 60, 80, 100, 120, 140];

Rn = Control.mid.RA(4);

Control.mid.D = 100*(Control.VisRatio.*Rn./Control.mid.RA).^(1/4);
Control.endo.D = 100*(Control.VisRatio.*Rn./Control.endo.RA).^(1/4);
Control.epi.D = 100*(Control.VisRatio.*Rn./Control.epi.RA).^(1/4);
