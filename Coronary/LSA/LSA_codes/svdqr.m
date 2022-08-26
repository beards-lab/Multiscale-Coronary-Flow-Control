function [ ] = svdqr(sens,INDMAP,data)
    
    %{ 

    This function computes the SVD followed by the QR decomposition of the
    sensitivity matrix with the prescribed parameters given in the index
    map INDMAP. 

    Inputs: 
    sens        - sensitivity matrix 
    INDMAP      - index map for parameter subset 
    data        - input data structure with data and global parameters 

    %} 

    % Relative singular value threshold 
    eta = 10 * data.gpars.DIFF_INC; 
    
    %% Assign sensitivity matrix for given parameter subset 

    S = sens(:,INDMAP);
    
    %% SVD

    % Perform SVD on the sensitivity matrix 
    [~, E, V] = svd(S); 
    
    % Find the rank of the sensitivity matrix 
    rho_1 = rank(S); 
    
    % Diagonalize E and implement threshold for singular values 
    E_hat = diag(E); 
    x = find(E_hat/max(E_hat) >= eta); 
    rho_2 = length(x); 
    
    % Partition V using either rho_1 or rho_2
    if rho_2 < rho_1
        V_rho = V(1:rho_2,:); 
    else
        V_rho = V(1:rho_1,:);
    end 

    %% QR decomposition
        
    % Perform QR factorization on V_rho
    [~, ~, P] = qr(V_rho); 
    
    % Reorder the index map using the permutation matrix P
    Theta_hat = P'*INDMAP'; 
    
    %% Determine active subset 

    disp('SVD-QR subset:')
    % Display parameter subset 
    if rho_2 < rho_1
        INDMAP_new = Theta_hat(1:rho_2); 
        INDMAP_new = sort(INDMAP_new); 
        disp(INDMAP_new')
    else 
        INDMAP_new = Theta_hat(1:rho_1); 
        INDMAP_new = sort(INDMAP_new); 
        disp(INDMAP_new')
    end 
end 