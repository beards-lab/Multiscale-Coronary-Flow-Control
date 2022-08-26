function [ ] = plot_LSA(Rsens,Isens,data)

    %{ 

    This function makes the plots for the ranked relative sensitivities
    calculated from the local sensitivity analysis. 

    Inputs: 
    Rsens   - ranked scalar sensitivities in descending order 
    Isens   - indices for Rsens 
    data    - input data structure with data and global parameters 

    %} 

    %% Unpack data structure 
    
    printfigs_on = data.printfigs_on; 
    pars_names      = data.pars_names; 
    DIFF_INC        = data.gpars.DIFF_INC; 
    
    %% Plots 
    
    % Threshold
    eta = 10 * DIFF_INC; 

    % Relative sensitivity ranking 
    hfig1 = figure(1); 
    clf
    set(gcf,'units','normalized','outerposition',[0.1 0.1 .6 .6]);
    set(gcf,'renderer','Painters')
    
    bar([1:length(Rsens)],Rsens/max(Rsens),'b','facealpha',.5)
    hold on
    plot([0 length(Rsens)+1],eta * ones(2,1),'k--')
    txt = '$\eta$'; 
    text(length(Isens)+1,eta,txt,'interpreter','latex','FontSize',20)
    
    set(gca,'FontSize',20)
    
    xlim([0 length(Isens)+1])
    xlabel('Parameters')
    Xlabel = pars_names(Isens); 
    Xtick = 1:length(Isens);
    set(gca,'xtick',Xtick)
    set(gca,'TickLabelInterpreter','latex')
    set(gca,'XTickLabels',Xlabel)
    
    ylim([1e-4 1])
    %ylabel('Total Sobol'' Indices')
    ytick = [1e-4 1e-2 1]; 
    set(gca,'Ytick',ytick)
    set(gca,'YScale','log')

    %% Print figure 

    if printfigs_on == 1 
        if ~exist('Figures', 'dir')
            mkdir('Figures')
        end
        if ~exist('Figures/LSA', 'dir')
            mkdir('Figures/LSA')
        end

        print(hfig1,'-dpng','Figures/LSA/F1_RSens.png')

    end 
    
    
        
end 



