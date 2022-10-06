function pars = reassigncompliances(pars,data,outputs)


%% 

params_perf = exp(pars.perfusion.params); 

Ra_0   = params_perf(7); 
Va_0   = params_perf(9); 
rf_epi = params_perf(17); 
rf_mid = params_perf(18); 

%% 

i_4per = outputs.i_4per; % indices for last 4 periods 

Ra_epi = outputs.epi.Ra(i_4per);
Ra_mid = outputs.mid.Ra(i_4per);
Ra_end = outputs.end.Ra(i_4per); 

PC_epi = outputs.epi.PC(i_4per);
PC_mid = outputs.mid.PC(i_4per);
PC_end = outputs.end.PC(i_4per); 

%% 

Ra_epi_bar = mean(Ra_epi); 
Ra_mid_bar = mean(Ra_mid); 
Ra_end_bar = mean(Ra_end); 

Ca_epi_new = Ra_mid_bar * (outputs.epi.D / 100)^(-4); 
Ca_mid_new = Ra_mid_bar * (outputs.mid.D / 100)^(-4); 
Ca_end_new = Ra_mid_bar * (outputs.end.D / 100)^(-4); 

Ra_epi_new = (Ca_epi_new / Ra_epi_bar) * Ra_epi; 
Ra_mid_new = (Ca_mid_new / Ra_mid_bar) * Ra_mid; 
Ra_end_new = (Ca_end_new / Ra_end_bar) * Ra_end;

Ca_epi = abs( (sqrt( rf_epi * Ra_0 ./ Ra_epi_new) - 1) * Va_0 ./ PC_epi ); 
Ca_mid = abs( (sqrt( rf_mid * Ra_0 ./ Ra_mid_new) - 1) * Va_0 ./ PC_mid ); 
Ca_end = abs( (sqrt( Ra_0 ./ Ra_end_new) - 1) * Va_0 ./ PC_end );

Ca_epi = mean(Ca_epi); 
Ca_mid = mean(Ca_mid); 
Ca_end = mean(Ca_end); 

params_perf(12) = Ca_epi; 
params_perf(13) = Ca_mid; 
params_perf(14) = Ca_end;

pars.perfusion.params = log(params_perf); 







