function Results = PerfusionModel(Case, flg)

t = Case.t; 

t_final = t(end);
Params  = Case.Params;
dt = Case.dt; 
T = Case.T; 

%% Rest/exercise is modeled using the aortic pressure as the input pressure.
Xo_myo = [Case.AoP(1) Case.Qexp(1)/60 50 50 85 85 120 120 5]'; % for 2713 Resting

sol = ode15s(@dXdT_myocardium,[0 t_final],Xo_myo, [], Case, Params,0);
sols = deval(t,sol); 
sols = sols'; 

o = zeros(length(t),27); 
for i = 1:length(t)
    [~,o(i,:)] = dXdT_myocardium(t(i),sols(i,:),Case,Params,1); 
end 

Results.t    = t; 
Results.P_PA = sols(:,1); % penetrating artery pressure
Results.Q_PA = sols(:,2); % inlet flow penetrating artery
Results.P11  = sols(:,3);
Results.P21  = sols(:,4);
Results.P12  = sols(:,5);
Results.P22  = sols(:,6);
Results.P13  = sols(:,7);
Results.P23  = sols(:,8);
Results.P_PV = sols(:,9); % penetrating vein pressure

Results.V11 = o(:,1); 
Results.V21 = o(:,2); 
Results.R11 = o(:,3); 
Results.R21 = o(:,4); 
Results.Rm1 = o(:,5); 
Results.Q11 = o(:,6); 
Results.Qm1 = o(:,7); 
Results.V12 = o(:,8); 
Results.V22 = o(:,9); 
Results.R12 = o(:,10); 
Results.R22 = o(:,11); 
Results.Rm2 = o(:,12);
Results.Q12 = o(:,13); 
Results.Qm2 = o(:,14); 
Results.V13 = o(:,15); 
Results.V23 = o(:,16); 
Results.R13 = o(:,17); 
Results.R23 = o(:,18); 
Results.Rm3 = o(:,19); 
Results.Q13 = o(:,20); 
Results.Qm3 = o(:,21); 
Results.Q21 = o(:,22); 
Results.Q22 = o(:,23); 
Results.Q23 = o(:,24); 
Results.Q_ima = o(:,25); 
Results.Q_imv = o(:,26); 
Results.Q_out = o(:,27); 

t_idx = t>t_final-2*T & t<=t_final;

Qendo = Results.Q13(t>t_final-2*T & t<=t_final);
Qendo = sum(Results.Q13(t_idx).*dt)/(2*T);

Qmid = Results.Q12(t>t_final-2*T & t<t_final);
Qmid = sum(Results.Q12(t_idx).*dt)/(2*T);

Qepi = Results.Q11(t>t_final-2*T & t<t_final);
Qepi = sum(Results.Q11(t_idx).*dt)/(2*T);

Results.ENDOEPI = Qendo/Qepi;
Results.ENDOMID = Qendo/Qmid;

disp(['ENDO/EPI = ',num2str(Qendo/Qepi)]);    


%% Plot figures 

if flg==1
    
    
    
    h1 = figure(1); 
    clf
    hold on
    plot(t,60*Results.Q13,'b','LineWidth',2);
    plot(t,60*Results.Q12,'g','LineWidth',2);
    plot(t,60*Results.Q11,'r','LineWidth',2);
    xlim([t(1) t(end)]);
    xlabel('Time (s)','FontSize',16);
    ylabel('Myocardial Flow (mL/min)','FontSize',16);
    set(gca,'Fontsize',16);
    
    figure(2)
    clf
    hold on
    pl(1) = plot(t,60*sols(:,2),'linewidth',2);
    pl(2) = plot(t,Case.Qexp,'linewidth',3,'Color',[0 0 0 0.4]);
    ylabel('Myocardial Flow (mL/min)');
    box on;
    set(gca,'Fontsize',16);
    xlim([t(1) t(end)]);
    xlabel('time (s)');
    if Case.Exercise_LvL == 1
        legend_handle = legend([pl(2),pl(1)],{'Data','Model'},'Fontsize',16,'Location','northeast');
        set(legend_handle, 'box' , 'off')
    end
    
    figure(3) 
    clf
    hold on
    plot(t,Case.AoP,'linewidth',1.5);
    plot(t,Results.P_PA,'linewidth',1.5); 
    plot(t,Case.PLV,'Color',[1 0 0 0.4],'linewidth',1.5);
    ylabel('Pressure (mmHg)');
    xlabel('time (s)');
    box on;
    if Case.Exercise_LvL == 1
        legend_handle = legend('Aortic','P_{PA}','LV','Fontsize',16,'Location','southwest');
        set(legend_handle, 'box' , 'on')
    end
    ylim([-10 180]);
    set(gca,'Fontsize',16);
    xlim([t(1) t(end)]);
    
    figure(4)
    clf
    hold on
    plot(t,Results.P13,'b','LineWidth',2);
    plot(t,Results.P12,'g','LineWidth',2);
    plot(t,Results.P11,'r','LineWidth',2);
    plot(Case.t,Case.PLV,'Color',[0 0 0 0.2],'linewidth',1.5);
    xlim([t(1) t(end)]);
    xlabel('time (s)','FontSize',16);
    ylabel('Pressure (mmHg)','FontSize',16);
    legend('subendo','midwall','subepi','FontSize',16,'location','best');
    set(gca,'Fontsize',16);
    
end
