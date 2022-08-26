function [ ] = covariance(sens,INDMAP)
    
    %{ 

    This function computes the covariance matrix and determines which
    parameters within the given subset in INDMAP are pairwise correlated. 

    Inputs: 
    sens        - sensivitity matrix 
    INDMAP      - index map for parameter subset 
    
    Outputs: upper triangular covariance matrix and pairwise correlations 

    %} 

    %% Assign sensitivity matrix for given parameter subset 

    S = sens(:,INDMAP);
    
    %% Compute model Hessian

    A  = S'*S;
    Ai = inv(A);
    disp('condition number of A = transpose(S)S and S');
    disp([ cond(A) cond(S) cond(Ai)] );
    
    %% Calculate and output the covariance matrix
    
    [a,b] = size(Ai);
    for i = 1:a
        for j = 1:b
            r(i,j)=Ai(i,j)/sqrt(Ai(i,i)*Ai(j,j)); % covariance matrix
        end
    end
    
    rn = triu(r,1); % extract upper triangular part of the matrix
    disp('Correlation matrix upper triangle')
    disp(rn)
    
    %% Determine pairwise correlated parameters 

    tol = .9; 
    [i,j] = find(abs(rn)>tol); % parameters with a value bigger than 0.95 are correlated
    
    disp('Correlated parameters:');
    for k = 1:length(i)
       disp([INDMAP(i(k)),INDMAP(j(k)),rn(i(k),j(k))]);
    end
    if isempty(i)
        disp('NONE')
    end 

end 