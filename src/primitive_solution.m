function [S, L] = primitive_solution(I)
    [U, Sigma, V] = svd(I, 'econ');
    V = V';
    U_prime = U(:, 1:3);
    Sigma_prime = Sigma(1:3, 1:3);
    V_prime = V(1:3, :);

    Sigma_root = Sigma_prime .^ 0.5;
    S = U_prime * Sigma_root;
    L = Sigma_root * V_prime;
end