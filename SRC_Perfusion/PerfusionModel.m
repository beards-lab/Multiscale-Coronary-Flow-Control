function Results = PerfusionModel(Case, flg)

%% Exercise is modeled using the aortic pressure as the input pressure.
Xo_myo = [Case.AoP(1) 1 50 50 85 85 120 120 5]'; % for 2713 Resting

t_final = Case.t(end);
Params = Case.Params;

Case.dPLVdt = TwoPtDeriv(Case.PLV,Case.dt);

[t,X] = ode15s(@dXdT_myocardium,[0 t_final],Xo_myo, [], Case, Params);

Results = PostProcessing( t, X, Case, Params);
Results.t = t;

t_idx = t>t_final-2*Case.T & t<=t_final;
Dt = diff(Results.t);

Qendo = Results.Q13(t>t_final-2*Case.T & t<=t_final);
Qendo = sum(Results.Q13(t_idx).*Dt(t_idx(2:end)))/(2*Case.T);

Qmid = Results.Q12(t>t_final-2*Case.T & t<t_final);
Qmid = sum(Results.Q12(t_idx).*Dt(t_idx(2:end)))/(2*Case.T);

Qepi = Results.Q11(t>t_final-2*Case.T & t<t_final);
Qepi = sum(Results.Q11(t_idx).*Dt(t_idx(2:end)))/(2*Case.T);


Results.ENDOEPI = Qendo/Qepi;
Results.ENDOMID = Qendo/Qmid;

if flg==1
    
    
    disp(['ENDO/EPI = ',num2str(Qendo/Qepi)]);    
    
    h1 = figure;hold on;
    plot(t,60*Results.Q13,'b','LineWidth',2);
    plot(t,60*Results.Q12,'g','LineWidth',2);
    plot(t,60*Results.Q11,'r','LineWidth',2);
    xlim([5 10]);
    xlabel('time (s)','FontSize',16);
    ylabel('Myocardial Flow (ml/min)','FontSize',16);
    set(gca,'Fontsize',16);
    
    box on;
    if Case.Exercise_LvL == 1
        ax1 = gca;
        hp = figure;
        
        ax2 = copyobj(ax1,hp);
        ax1Chil = ax1.Children;
        copyobj(ax1Chil, ax2)
        
        legend('subendo','midwall','subepi','FontSize',16,'location','best');
        set(gcf,'Position',[0,0,1024,1024]);
        legend_handle = legend('Orientation','horizontal');
        set(gcf,'Position',(get(legend_handle,'Position')...
            .*[0, 0, 1, 1].*get(gcf,'Position')));
        set(legend_handle,'Position',[0,0,1,1]);
        set(gcf, 'Position', get(gcf,'Position') + [500, 400, 0, 0]);
        
    end
    
    
    figure; hold on;
    pl(1) = plot(t,60*X(:,2),'linewidth',2);
    pl(2) = plot(Case.t,Case.Qexp,'linewidth',3,'Color',[0 0 0 0.4]);
    ylabel('Myocardial Flow (ml/min)');
    box on;
    set(gca,'Fontsize',16);
    xlim([5 10]);
    xlabel('time (s)');
    if Case.Exercise_LvL == 1
        legend_handle = legend([pl(2),pl(1)],{'Data','Model'},'Fontsize',16,'Location','northeast');
        set(legend_handle, 'box' , 'off')
    end
    
    figure; hold on;
    plot(Case.t,Case.AoP,'linewidth',1.5);
    plot(Case.t,Case.PLV,'Color',[1 0 0 0.4],'linewidth',1.5);
    ylabel('Pressure (mmHg)');
    xlabel('time (s)');
    box on;
    if Case.Exercise_LvL == 1
        legend_handle = legend('Aortic','LV','Fontsize',16,'Location','southwest');
        set(legend_handle, 'box' , 'on')
    end
    ylim([-10 180]);
    set(gca,'Fontsize',16);
    
    figure;hold on;
    plot(t,Results.P13,'b','LineWidth',2);
    plot(t,Results.P12,'g','LineWidth',2);
    plot(t,Results.P11,'r','LineWidth',2);
    plot(Case.t,Case.PLV,'Color',[0 0 0 0.2],'linewidth',1.5);
    xlim([5 10]);
    xlabel('time (s)','FontSize',16);
    ylabel('Pressure (mmHg)','FontSize',16);
    legend('subendo','midwall','subepi','FontSize',16,'location','best');
    set(gca,'Fontsize',16);
    
end
