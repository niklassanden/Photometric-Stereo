function [S, L] = upgrade_constant_albedo(S_hat, L_hat)
    % Upgrade
    coeff = [S_hat(:, 1) .^ 2, 2 * S_hat(:, 1) .* S_hat(:, 2), 2 * S_hat(:, 1) .* S_hat(:, 3), ...
        S_hat(:, 2) .^ 2, 2 * S_hat(:, 2) .* S_hat(:, 3), S_hat(:, 3) .^ 2];

    B_nums = coeff \ ones(length(S_hat), 1);
    B = [B_nums(1), B_nums(2), B_nums(3)
        B_nums(2), B_nums(4), B_nums(5)
        B_nums(3), B_nums(5), B_nums(6)];

    [W, Pi, ~] = svd(B);
    A = W * Pi .^ 0.5;
    S = S_hat * A;
    L = A \ L_hat;
end