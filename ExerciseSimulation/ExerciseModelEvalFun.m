function [Rest, Exercise] = ExerciseModelEvalFun2(xendo,xmid,xepi, Control, MetSignal)


%% Read aortic and left venctricular pressure from the
data_rest = xlsread('TuneExercisePig','2713 Resting','B9:D5005');
data_exercise = xlsread('TuneExercisePig','2713 Exercise Level 2','B9:D5005');

[tdata_R,AoP_R,PLV_R,Flow_R, FlowExpRest] = ReadExerciseInput(data_rest);
[tdata_E,AoP_E,PLV_E,Flow_E, FlowExpEx] = ReadExerciseInput(data_exercise);

% Assign baseline blood gas measurements from CPP=120 mmHg case (k = 5), Pig C
k = 5;
Init.ArtO2Cnt   = Control.ArtO2Cnt(k);
Init.CVO2Cnt    = Control.CVO2Cnt(k);
Init.ArtPO2     = Control.ArtPO2(k);
Init.CvPO2      = Control.CvPO2(k);
Init.ArtO2Sat   = Control.ArtO2Sat(k);
Init.CvO2Sat    = Control.CvO2Sat(k);
Init.Hgb        = Control.Hgb(k);
Init.HCT        = Control.HCT(k);
Init.VisRatio   = Control.VisRatio(k);
Init.LVweight   = Control.LVweight;

%% Rest
Init.Exercise_LvL = 1.00;
MVO2 = 60;
Init.MVO2 = Init.Exercise_LvL*MVO2;

Init.Params = PerfusionModel_ParamSet();

Init.t = tdata_R;
Init.dt = mean(diff(Init.t));
Init.AoP = AoP_R;
Init.PLV = PLV_R;
Init.Qexp = Flow_R;
[~, Init.T] = LeftVenPerssure(Init.AoP,Init.t,Init.dt);
Init.HR = 60/Init.T;

Init.Results = PerfusionModel( Init, 0);
Init =   Calculations_Exercise(Init, 'Baseline');

%% Initialize Rest

Rest = Init;

QPA = Rest.QPA;

%% Run Rest

err = 10;
c = 1;
while err>1e-3 && c<50
    
    [Rest.endo.D, Rest.Act_Endo, Rest.S_myo_Endo, Rest.S_meta_Endo, Rest.S_HR_Endo] = RepModel_Exercise(Rest, Control, 'endo', xendo, MetSignal);
    
    [Rest.mid.D, Rest.Act_Mid, Rest.S_myo_Mid, Rest.S_meta_Mid, Rest.S_HR_Mid] = RepModel_Exercise(Rest, Control, 'mid', xmid, MetSignal);
    
    [Rest.epi.D, Rest.Act_Epi, Rest.S_myo_Epi, Rest.S_meta_Epi, Rest.S_HR_Epi] = RepModel_Exercise(Rest, Control, 'epi', xepi, MetSignal);
    
    [C11, C12, C13] = ComplianceResistance(Rest);
    
    Rest.Params.C11 = C11;
    Rest.Params.C12 = C12;
    Rest.Params.C13 = C13;
    
    Rest.Results = PerfusionModel( Rest, 0);
    
    Rest =   Calculations_Exercise(Rest, 'Exercise');
       
    err = abs(QPA - Rest.QPA);
    QPA = Rest.QPA;
    
    c = c+1;
    
end
Rest.Results = PerfusionModel( Rest, 1);

%% Initialize Exercise
Init.Exercise_LvL = 1.32;
MVO2 = 60;
Init.MVO2 = Init.Exercise_LvL*MVO2;

Init.Params = PerfusionModel_ParamSet();

Init.t = tdata_E;
Init.dt = mean(diff(Init.t));
Init.AoP = AoP_E;
Init.PLV = PLV_E;
Init.Qexp = Flow_E;
[~, Init.T] = LeftVenPerssure(Init.AoP,Init.t,Init.dt);
Init.HR = 60/Init.T;

Init.Results = PerfusionModel( Init, 0);
Init =   Calculations_Exercise(Init, 'NoBaseline');

Exercise = Init;

QPA = Exercise.QPA;

%% Run Exercise

err = 10;
c = 1;
while err>1e-3 && c<50
    
    [Exercise.endo.D, Exercise.Act_Endo, Exercise.S_myo_Endo, Exercise.S_meta_Endo, Exercise.S_HR_Endo] = RepModel_Exercise(Exercise, Control, 'endo', xendo, MetSignal);
    
    [Exercise.mid.D, Exercise.Act_Mid, Exercise.S_myo_Mid, Exercise.S_meta_Mid, Exercise.S_HR_Mid] = RepModel_Exercise(Exercise, Control, 'mid', xmid, MetSignal);
    
    [Exercise.epi.D, Exercise.Act_Epi, Exercise.S_myo_Epi, Exercise.S_meta_Epi, Exercise.S_HR_Epi] = RepModel_Exercise(Exercise, Control, 'epi', xepi, MetSignal);
    
    [C11, C12, C13] = ComplianceResistance(Exercise);
    
    Exercise.Params.C11 = C11;
    Exercise.Params.C12 = C12;
    Exercise.Params.C13 = C13;
    
    Exercise.Results = PerfusionModel( Exercise, 0);
    
    Exercise =   Calculations_Exercise(Exercise, 'Exercise');
       
    err = abs(QPA - Exercise.QPA);
    QPA = Exercise.QPA;
    
    c = c+1;
    
end

Exercise.Results = PerfusionModel( Exercise, 1);

%% Plots

figure;

%% Check these values please!
subplot(1,2,1);hold on
plot(1,FlowExpRest,'k+','MarkerSize',12,'LineWidth',2);
plot(1,60*Rest.QPA,'ko','MarkerSize',8,'linewidth',2);
plot(2,60*Exercise.QPA,'ko','MarkerSize',8,'linewidth',2);
plot(2,FlowExpEx,'k+','MarkerSize',12,'LineWidth',2);
set(gca,'xtick',[1,2,3],'xticklabel',{'Rest','Exercise'},'Fontsize',16);
ylabel('F, Myocardial Flow (ml/min)','Fontsize',16);
axis([0.5 2.5 0 60*Exercise.QPA*1.3]);box on;pbaspect([1 2 1]);
legend('Data','Model','Location','south','Fontsize',13);

subplot(1,2,2);hold on
plot([0 4],[1.25 1.25],'--','Color',[128,128,128]/255,'linewidth',2);
plot(1,Rest.Results.ENDOEPI,'ko','MarkerSize',8,'linewidth',2);
plot([0 4],[1.00 1.00],'--','Color',[128,128,128]/255,'linewidth',2);
plot(2,Exercise.Results.ENDOEPI,'ko','MarkerSize',8,'linewidth',2);
set(gca,'xtick',[1,2,3],'xticklabel',{'Rest','Exercise'},'Fontsize',16);
ylabel('ENDO/EPI Flow Ratio','Fontsize',14);
axis([0.5 2.5 0 1.5]);box on;pbaspect([1 2 1]);
legend('Literature Data','Model','Location','best','Fontsize',13);


figure;
subplot(1,2,1);
plot([1 2],[Rest.Act_Epi, Exercise.Act_Epi],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color',[1 0 0 0.3]); hold on;
plot([1 2],[Rest.Act_Mid, Exercise.Act_Mid],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color',[0 1 0 0.3]);
plot([1 2],[Rest.Act_Endo, Exercise.Act_Endo],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color',[0 0 1 0.3]);
set(gca,'xtick',[1,2],'xticklabel',{'Rest','Exercise'},'Fontsize',14);
axis([0.5 2.5 0 1.0]);ylabel('A, Activation (unitless)');pbaspect([1 2 1]);
legend('subepi','midwall','subendo','Location','best');
set(gca,'Fontsize',14);

subplot(1,2,2);
plot([1 2],[Rest.epi.D/100, Exercise.epi.D/100],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color',[1 0 0 0.3]); hold on;
plot([1 2],[Rest.mid.D/100, Exercise.mid.D/100],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color',[0 1 0 0.3]);
plot([1 2],[Rest.endo.D/100, Exercise.endo.D/100],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color',[0 0 1 0.3]);
set(gca,'xtick',[1,2],'xticklabel',{'Rest','Exercise'},'Fontsize',14);
axis([0.5 2.5 0.0 1.5]);ylabel('D_n, Normalized Diameter (unitless)','FontName','Arial');pbaspect([1 2 1]);
set(gca,'Fontsize',14);
% legend('subepi','midwall','subendo');

h1 = figure;

Rest.Stotal_Epi = Rest.S_myo_Epi - Rest.S_meta_Epi - Rest.S_HR_Epi + xepi(end-1);
Rest.Stotal_Mid = Rest.S_myo_Mid - Rest.S_meta_Mid - Rest.S_HR_Mid + xmid(end-1);
Rest.Stotal_Endo = Rest.S_myo_Endo - Rest.S_meta_Endo - Rest.S_HR_Endo + xendo(end-1);
Exercise.Stotal_Epi = Exercise.S_myo_Epi - Exercise.S_meta_Epi - Exercise.S_HR_Epi + xepi(end-1);
Exercise.Stotal_Mid = Exercise.S_myo_Mid - Exercise.S_meta_Mid - Exercise.S_HR_Mid + xmid(end-1);
Exercise.Stotal_Endo = Exercise.S_myo_Endo - Exercise.S_meta_Endo - Exercise.S_HR_Endo + xendo(end-1);


set(h1,'Position',[10 10 1000 500]);
subplot(1,3,1);
plot([1 2],[Rest.S_myo_Epi, Exercise.S_myo_Epi],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color',[1 0 0 0.3]); hold on;
plot([1 2],[Rest.S_myo_Mid, Exercise.S_myo_Mid],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color',[0 1 0 0.3]);
plot([1 2],[Rest.S_myo_Endo, Exercise.S_myo_Endo],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color',[0 0 1 0.3]);
set(gca,'xtick',[1,2],'xticklabel',{'Rest','Exercise'},'Fontsize',14);
xlim([0.5 2.5]);ylabel('S_{myo}','Fontsize',14);pbaspect([1 2 1]);
set(gca,'Fontsize',14);

subplot(1,3,2);
plot([1 2],[Rest.S_meta_Epi, Exercise.S_meta_Epi],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color',[1 0 0 0.3]); hold on;
plot([1 2],[Rest.S_meta_Mid, Exercise.S_meta_Mid],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color',[0 1 0 0.3]);
plot([1 2],[Rest.S_meta_Endo, Exercise.S_meta_Endo],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color',[0 0 1 0.3]);
set(gca,'xtick',[1,2],'xticklabel',{'Rest','Exercise'},'Fontsize',14);
xlim([0.5 2.5]);ylabel('S_{meta}','Fontsize',14);pbaspect([1 2 1]);
set(gca,'Fontsize',14);

subplot(1,3,3);
plot([1 2],[Rest.S_HR_Epi, Exercise.S_HR_Epi],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color',[1 0 0 0.3]); hold on;
plot([1 2],[Rest.S_HR_Mid, Exercise.S_HR_Mid],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color',[0 1 0 0.3]);
plot([1 2],[Rest.S_HR_Endo, Exercise.S_HR_Endo],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color',[0 0 1 0.3]);
set(gca,'xtick',[1,2],'xticklabel',{'Rest','Exercise'},'Fontsize',14);
xlim([0.5 2.5]);ylabel('S_{HR}','Fontsize',14);pbaspect([1 2 1]);
set(gca,'Fontsize',14);

figure;
 
Rest.S_Epi = [Rest.Stotal_Epi Rest.S_myo_Epi	-Rest.S_HR_Epi  -Rest.S_meta_Epi];
Rest.S_Mid = [Rest.Stotal_Mid Rest.S_myo_Mid	-Rest.S_HR_Mid  -Rest.S_meta_Mid];
Rest.S_Endo = [Rest.Stotal_Endo Rest.S_myo_Endo	-Rest.S_HR_Endo -Rest.S_meta_Endo];
Exercise.S_Epi = [Exercise.Stotal_Epi	Exercise.S_myo_Epi	-Exercise.S_HR_Epi      -Exercise.S_meta_Epi];
Exercise.S_Mid = [Exercise.Stotal_Mid	Exercise.S_myo_Mid	-Exercise.S_HR_Mid      -Exercise.S_meta_Mid];
Exercise.S_Endo = [Exercise.Stotal_Endo Exercise.S_myo_Endo	-Exercise.S_HR_Endo     -Exercise.S_meta_Endo];

DS_Epi = Exercise.S_Epi-Rest.S_Epi;
DS_Mid = Exercise.S_Mid-Rest.S_Mid;
DS_Endo = Exercise.S_Endo-Rest.S_Endo;

Y = [DS_Epi;DS_Mid;DS_Endo];
X = categorical({'Subepi.','Midwall','Subendo.'});
X = reordercats(X,{'Subepi.','Midwall','Subendo.'});
b = bar(X,Y);

b(1).FaceColor = [128,128,128]/255;
ylabel('\DeltaS, Stimuli Change (Unitless)');
ylim([-4 4]);
legend('Total','Myogenic','Autonomic','Metabolic','Fontsize',14,'Location','northeast');
set(gca,'Fontsize',14);

return;