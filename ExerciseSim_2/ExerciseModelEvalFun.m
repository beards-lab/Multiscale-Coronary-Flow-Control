function Rest = ExerciseModelEvalFun(xendo,xmid,xepi, Control, MetSignal)
% This function couples the two models. The inputs are:
% xendo: optimized parameters for subendocardial layer
% xmid: optimized parameters for midwall layer
% xepi: optimized parameters for subepicardial layer
% Control: the initialization data
% MetSignal: {'QM','ATP','VariableSV','Generic','MVO2','QdS','Q','M2'};
% The outputs are two data structures: Rest and Exercise for each case
% The experimental data are read within this function.

%% Read aortic and left venctricular pressure from excel file containing data

% Load time vector and heart rate/period 
Init.t  = Control.Time; 
Init.dt = Control.dt; 

% Load heart period and rate 
Init.T  = Control.T; 
Init.HR = Control.HR; 

% Load time series 
Init.AoP    = Control.AoP; 
Init.PLV    = Control.PLV; 
Init.Qexp   = Control.Flow; 
Init.dPLVdt = Control.dPLVdt; 

% Load interpolants 
Init.AoPspl    = Control.AoPspl; 
Init.PLVspl    = Control.PLVspl; 
Init.dPLVdtspl = Control.dPLVdtspl; 

% Load blood gas measurements 
Init.ArtO2Cnt   = Control.ArtO2Cnt;
Init.CVO2Cnt    = Control.CVO2Cnt;
Init.ArtPO2     = Control.ArtPO2;
Init.CvPO2      = Control.CVPO2;
Init.ArtO2Sat   = Control.ArtO2Sat;
Init.CvO2Sat    = Control.CVO2Sat;
Init.Hgb        = Control.Hgb;
Init.HCT        = Control.HCT;
Init.VisRatio   = Control.VisRatio;

% Load heart weight 
Init.LVweight   = Control.LVWeight;

%% First we simulate rest
% structure init is formed to initialize the rest structure.
Init.Exercise_LvL = 1.00; % 1.00 means no exercise, MVO2 remains unchanged
MVO2 = 60; % Rest MVO2
Init.MVO2 = Init.Exercise_LvL*MVO2; 

% Initialize the parameters of the circulation model
Init.Params = PerfusionModel_ParamSet();

% Run an initialization and calculate cycle-to-cycle averages with the
% initalization
Init.Results = PerfusionModel( Init, 1); 
Init =   Calculations_Exercise(Init, 'Baseline');

% Copy initialization to Rest
Rest = Init;
QPA = Rest.QPA;

return 


%% Run rest
% The while loop iterates over the two models successively, starting with
% the representative vessel model. Given the cycle-to-cycle averages, the
% equivalent diameter and associated quantities (activation, metabolic,
% myogenic, and autonomic signals) are computed using representative vessel
% model (Step 1). Then, microvascular compliances C11, C12, and C13 are 
% calculated and updated (Step 2). And Lastly, the hemodynamics are updated
% in the myocardial circulatio model (Step 3). Step 1 - Step 3 are done 
% iteratively until total flow is converged or the 50 iterations are done.  
err = 10;
c = 1;
while err>1e-3 && c<50
    
    %% Step 1 - Representative vessel model
    [Rest.endo.D, Rest.Act_Endo, Rest.S_myo_Endo, Rest.S_meta_Endo, Rest.S_HR_Endo] = RepModel_Exercise(Rest, Control, 'endo', xendo, MetSignal);
    
    [Rest.mid.D, Rest.Act_Mid, Rest.S_myo_Mid, Rest.S_meta_Mid, Rest.S_HR_Mid] = RepModel_Exercise(Rest, Control, 'mid', xmid, MetSignal);
    
    [Rest.epi.D, Rest.Act_Epi, Rest.S_myo_Epi, Rest.S_meta_Epi, Rest.S_HR_Epi] = RepModel_Exercise(Rest, Control, 'epi', xepi, MetSignal);

    disp([Rest.endo.D, Rest.Act_Endo, Rest.S_myo_Endo, Rest.S_meta_Endo, Rest.S_HR_Endo; ...
        Rest.mid.D, Rest.Act_Mid, Rest.S_myo_Mid, Rest.S_meta_Mid, Rest.S_HR_Mid; ...
        Rest.epi.D, Rest.Act_Epi, Rest.S_myo_Epi, Rest.S_meta_Epi, Rest.S_HR_Epi; ...
        ])

    %% Step 2 - Approximation of microvascular resistances
    [C11, C12, C13] = ComplianceResistance(Rest);
    
    disp([C11, C12, C13])

    Rest.Params.C11 = C11;
    Rest.Params.C12 = C12;
    Rest.Params.C13 = C13;
    
    %% Step 3 - Myocardial circulation model
    Rest.Results = PerfusionModel( Rest, 0);
    Rest =   Calculations_Exercise(Rest, 'Exercise');
    
    %% Check the convergence error and update
    err = abs(QPA - Rest.QPA);
    QPA = Rest.QPA;
    
    c = c+1;
    
end

Rest.Results = PerfusionModel( Rest, 1);

% %% The we simulate exercise
% Init.Exercise_LvL = 1.32;
% MVO2 = 60;
% Init.MVO2 = Init.Exercise_LvL*MVO2;
% 
% Init.Params = PerfusionModel_ParamSet();
% 
% Init.t = tdata_E;
% Init.dt = mean(diff(Init.t));
% Init.AoP = AoP_E;
% Init.PLV = PLV_E;
% Init.Qexp = Flow_E;
% [~, Init.T] = LeftVenPerssure(Init.AoP,Init.t,Init.dt);
% Init.HR = 60/Init.T;
% 
% Init.Results = PerfusionModel( Init, 0);
% Init =   Calculations_Exercise(Init, 'NoBaseline');
% 
% Exercise = Init;
% 
% QPA = Exercise.QPA;
% 
% %% Run Exercise
% 
% err = 10;
% c = 1;
% while err>1e-3 && c<50
%     
%      %% Step 1 - Representative vessel model
%     [Exercise.endo.D, Exercise.Act_Endo, Exercise.S_myo_Endo, Exercise.S_meta_Endo, Exercise.S_HR_Endo] = RepModel_Exercise(Exercise, Control, 'endo', xendo, MetSignal);
%     
%     [Exercise.mid.D, Exercise.Act_Mid, Exercise.S_myo_Mid, Exercise.S_meta_Mid, Exercise.S_HR_Mid] = RepModel_Exercise(Exercise, Control, 'mid', xmid, MetSignal);
%     
%     [Exercise.epi.D, Exercise.Act_Epi, Exercise.S_myo_Epi, Exercise.S_meta_Epi, Exercise.S_HR_Epi] = RepModel_Exercise(Exercise, Control, 'epi', xepi, MetSignal);
%     
%     %% Step 2 - Approximation of microvascular resistances    
%     [C11, C12, C13] = ComplianceResistance(Exercise);
%     
%     Exercise.Params.C11 = C11;
%     Exercise.Params.C12 = C12;
%     Exercise.Params.C13 = C13;
% 
%     %% Step 3 - Myocardial circulation model
%     Exercise.Results = PerfusionModel( Exercise, 0);
%     Exercise =   Calculations_Exercise(Exercise, 'Exercise');
%     
%     %% Check the convergence error and update       
%     err = abs(QPA - Exercise.QPA);
%     QPA = Exercise.QPA;
%     
%     c = c+1;
%     
% end
% 
% Exercise.Results = PerfusionModel( Exercise, 1);
% 
% %% Plots
% 
% figure(101)
% 
% subplot(1,2,1);hold on
% plot(1,FlowExpRest,'k+','MarkerSize',12,'LineWidth',2);
% plot(1,60*Rest.QPA,'ko','MarkerSize',8,'linewidth',2);
% plot(2,60*Exercise.QPA,'ko','MarkerSize',8,'linewidth',2);
% plot(2,FlowExpEx,'k+','MarkerSize',12,'LineWidth',2);
% set(gca,'xtick',[1,2,3],'xticklabel',{'Rest','Exercise'},'Fontsize',16);
% ylabel('F, Myocardial Flow (ml/min)','Fontsize',16);
% axis([0.5 2.5 0 60*Exercise.QPA*1.3]);box on;pbaspect([1 2 1]);
% legend('Data','Model','Location','south','Fontsize',13);
% 
% subplot(1,2,2);hold on
% plot([0 4],[1.25 1.25],'--','Color',[128,128,128]/255,'linewidth',2);
% plot(1,Rest.Results.ENDOEPI,'ko','MarkerSize',8,'linewidth',2);
% plot([0 4],[1.00 1.00],'--','Color',[128,128,128]/255,'linewidth',2);
% plot(2,Exercise.Results.ENDOEPI,'ko','MarkerSize',8,'linewidth',2);
% set(gca,'xtick',[1,2,3],'xticklabel',{'Rest','Exercise'},'Fontsize',16);
% ylabel('ENDO/EPI Flow Ratio','Fontsize',14);
% axis([0.5 2.5 0 1.5]);box on;pbaspect([1 2 1]);
% legend('Literature Data','Model','Location','best','Fontsize',13);
% 
% 
% figure(102)
% subplot(1,2,1);
% plot([1 2],[Rest.Act_Epi, Exercise.Act_Epi],'o-','MarkerEdgeColor','r',...
%     'MarkerFaceColor','r','LineWidth',2,'Color',[1 0 0 0.3]); hold on;
% plot([1 2],[Rest.Act_Mid, Exercise.Act_Mid],'o-','MarkerEdgeColor','g',...
%     'MarkerFaceColor','g','LineWidth',2,'Color',[0 1 0 0.3]);
% plot([1 2],[Rest.Act_Endo, Exercise.Act_Endo],'o-','MarkerEdgeColor','b',...
%     'MarkerFaceColor','b','LineWidth',2,'Color',[0 0 1 0.3]);
% set(gca,'xtick',[1,2],'xticklabel',{'Rest','Exercise'},'Fontsize',14);
% axis([0.5 2.5 0 1.0]);ylabel('A, Activation (unitless)');pbaspect([1 2 1]);
% legend('subepi','midwall','subendo','Location','best');
% set(gca,'Fontsize',14);
% 
% subplot(1,2,2);
% plot([1 2],[Rest.epi.D/100, Exercise.epi.D/100],'o-','MarkerEdgeColor','r',...
%     'MarkerFaceColor','r','LineWidth',2,'Color',[1 0 0 0.3]); hold on;
% plot([1 2],[Rest.mid.D/100, Exercise.mid.D/100],'o-','MarkerEdgeColor','g',...
%     'MarkerFaceColor','g','LineWidth',2,'Color',[0 1 0 0.3]);
% plot([1 2],[Rest.endo.D/100, Exercise.endo.D/100],'o-','MarkerEdgeColor','b',...
%     'MarkerFaceColor','b','LineWidth',2,'Color',[0 0 1 0.3]);
% set(gca,'xtick',[1,2],'xticklabel',{'Rest','Exercise'},'Fontsize',14);
% axis([0.5 2.5 0.0 1.5]);ylabel('D_n, Normalized Diameter (unitless)','FontName','Arial');pbaspect([1 2 1]);
% set(gca,'Fontsize',14);
% % legend('subepi','midwall','subendo');
% 
% h1 = figure(103);
% 
% Rest.Stotal_Epi = Rest.S_myo_Epi - Rest.S_meta_Epi - Rest.S_HR_Epi + xepi(end-1);
% Rest.Stotal_Mid = Rest.S_myo_Mid - Rest.S_meta_Mid - Rest.S_HR_Mid + xmid(end-1);
% Rest.Stotal_Endo = Rest.S_myo_Endo - Rest.S_meta_Endo - Rest.S_HR_Endo + xendo(end-1);
% Exercise.Stotal_Epi = Exercise.S_myo_Epi - Exercise.S_meta_Epi - Exercise.S_HR_Epi + xepi(end-1);
% Exercise.Stotal_Mid = Exercise.S_myo_Mid - Exercise.S_meta_Mid - Exercise.S_HR_Mid + xmid(end-1);
% Exercise.Stotal_Endo = Exercise.S_myo_Endo - Exercise.S_meta_Endo - Exercise.S_HR_Endo + xendo(end-1);
% 
% 
% set(h1,'Position',[10 10 1000 500]);
% subplot(1,3,1);
% plot([1 2],[Rest.S_myo_Epi, Exercise.S_myo_Epi],'o-','MarkerEdgeColor','r',...
%     'MarkerFaceColor','r','LineWidth',2,'Color',[1 0 0 0.3]); hold on;
% plot([1 2],[Rest.S_myo_Mid, Exercise.S_myo_Mid],'o-','MarkerEdgeColor','g',...
%     'MarkerFaceColor','g','LineWidth',2,'Color',[0 1 0 0.3]);
% plot([1 2],[Rest.S_myo_Endo, Exercise.S_myo_Endo],'o-','MarkerEdgeColor','b',...
%     'MarkerFaceColor','b','LineWidth',2,'Color',[0 0 1 0.3]);
% set(gca,'xtick',[1,2],'xticklabel',{'Rest','Exercise'},'Fontsize',14);
% xlim([0.5 2.5]);ylabel('S_{myo}','Fontsize',14);pbaspect([1 2 1]);
% set(gca,'Fontsize',14);
% 
% subplot(1,3,2);
% plot([1 2],[Rest.S_meta_Epi, Exercise.S_meta_Epi],'o-','MarkerEdgeColor','r',...
%     'MarkerFaceColor','r','LineWidth',2,'Color',[1 0 0 0.3]); hold on;
% plot([1 2],[Rest.S_meta_Mid, Exercise.S_meta_Mid],'o-','MarkerEdgeColor','g',...
%     'MarkerFaceColor','g','LineWidth',2,'Color',[0 1 0 0.3]);
% plot([1 2],[Rest.S_meta_Endo, Exercise.S_meta_Endo],'o-','MarkerEdgeColor','b',...
%     'MarkerFaceColor','b','LineWidth',2,'Color',[0 0 1 0.3]);
% set(gca,'xtick',[1,2],'xticklabel',{'Rest','Exercise'},'Fontsize',14);
% xlim([0.5 2.5]);ylabel('S_{meta}','Fontsize',14);pbaspect([1 2 1]);
% set(gca,'Fontsize',14);
% 
% subplot(1,3,3);
% plot([1 2],[Rest.S_HR_Epi, Exercise.S_HR_Epi],'o-','MarkerEdgeColor','r',...
%     'MarkerFaceColor','r','LineWidth',2,'Color',[1 0 0 0.3]); hold on;
% plot([1 2],[Rest.S_HR_Mid, Exercise.S_HR_Mid],'o-','MarkerEdgeColor','g',...
%     'MarkerFaceColor','g','LineWidth',2,'Color',[0 1 0 0.3]);
% plot([1 2],[Rest.S_HR_Endo, Exercise.S_HR_Endo],'o-','MarkerEdgeColor','b',...
%     'MarkerFaceColor','b','LineWidth',2,'Color',[0 0 1 0.3]);
% set(gca,'xtick',[1,2],'xticklabel',{'Rest','Exercise'},'Fontsize',14);
% xlim([0.5 2.5]);ylabel('S_{HR}','Fontsize',14);pbaspect([1 2 1]);
% set(gca,'Fontsize',14);
% 
% figure(104);
%  
% Rest.S_Epi = [Rest.Stotal_Epi Rest.S_myo_Epi	-Rest.S_HR_Epi  -Rest.S_meta_Epi];
% Rest.S_Mid = [Rest.Stotal_Mid Rest.S_myo_Mid	-Rest.S_HR_Mid  -Rest.S_meta_Mid];
% Rest.S_Endo = [Rest.Stotal_Endo Rest.S_myo_Endo	-Rest.S_HR_Endo -Rest.S_meta_Endo];
% Exercise.S_Epi = [Exercise.Stotal_Epi	Exercise.S_myo_Epi	-Exercise.S_HR_Epi      -Exercise.S_meta_Epi];
% Exercise.S_Mid = [Exercise.Stotal_Mid	Exercise.S_myo_Mid	-Exercise.S_HR_Mid      -Exercise.S_meta_Mid];
% Exercise.S_Endo = [Exercise.Stotal_Endo Exercise.S_myo_Endo	-Exercise.S_HR_Endo     -Exercise.S_meta_Endo];
% 
% DS_Epi = Exercise.S_Epi-Rest.S_Epi;
% DS_Mid = Exercise.S_Mid-Rest.S_Mid;
% DS_Endo = Exercise.S_Endo-Rest.S_Endo;
% 
% Y = [DS_Epi;DS_Mid;DS_Endo];
% X = categorical({'Subepi.','Midwall','Subendo.'});
% X = reordercats(X,{'Subepi.','Midwall','Subendo.'});
% b = bar(X,Y);
% 
% b(1).FaceColor = [128,128,128]/255;
% ylabel('\DeltaS, Stimuli Change (Unitless)');
% ylim([-4 4]);
% legend('Total','Myogenic','Autonomic','Metabolic','Fontsize',14,'Location','northeast');
% set(gca,'Fontsize',14);

return;
%}

