%--------------------------------------------------------------------------
%Used to fix some parameters and let the others vary (INDMAP) before
%solving ODE
%--------------------------------------------------------------------------

function [J,sol,rout] = model_wrap(scalepars,data)

    %{

    This function wraps around model_sol to modify only the parameters
    optimized. 

    Inputs: 
    pars    - vector of parameters to optimize 
    data    - input data structure with data and global parameters 

    Outpus: 
    J       - cost functional
    sol     - solution output structure from model_sol_exvivo.m 
    rout    - residual vector 

    %}

    ALLPARS = data.gpars.ALLPARS;
    INDMAP  = data.gpars.INDMAP;
    
    tpars = ALLPARS;
    tpars(INDMAP') = scalepars;
    
    [sol,rout,J] = model_sol(tpars,data);

end 
