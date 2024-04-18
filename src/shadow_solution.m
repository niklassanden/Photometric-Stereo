function [S, L, illuminated] = shadow_solution(I, threshold)
    arguments
        I
        threshold = 40
    end

    p = size(I, 1);
    num_images = size(I, 2);
    take_rows = true(p, 1);
    take_cols = true(num_images, 1);

    shadowed = false(p, num_images);
    for i = 1:num_images
        shadowed(:, i) = I(:, i) <= threshold;
    end

    while take_rows' * shadowed * take_cols > 0
        if nnz(take_rows) > nnz(take_cols)
            num_remove = nnz(take_rows) - nnz(take_cols);

            num_shadows_row = shadowed * take_cols;
            [~, inds] = sort(num_shadows_row, "descend");
            num_remove = min(num_remove, nnz(num_shadows_row));
            take_rows(inds(1:num_remove)) = false;
        else
            [~, ind_remove] = max(shadowed' * take_rows);
            take_cols(ind_remove) = false;
        end

    end

    I_tilde = I(take_rows, take_cols);
    [U, Sigma, V] = svd(I_tilde, "econ");
    V = V';
    U_prime = U(:, 1:3);
    Sigma_prime = Sigma(1:3, 1:3);
    V_prime = V(1:3, :);

    Sigma_root = Sigma_prime .^ 0.5;
    S_tilde = U_prime * Sigma_root;
    L_tilde = Sigma_root * V_prime;
    S = zeros(p, 3);
    S(take_rows, :) = S_tilde;
    L = zeros(3, num_images);
    L(:, take_cols) = L_tilde;

    illuminated = ~shadowed;
    while nnz(take_rows) < p || nnz(take_cols) < num_images
        if nnz(take_cols) == num_images
            % Calculate the rest of the surface normals
            for i = 1:p
                if take_rows(i)
                    continue
                end
                S(i, :) = L(:, illuminated(i, :))' \ I(i, illuminated(i, :))';
            end

            take_rows = true(p, 1);

        elseif nnz(take_rows) < nnz(take_cols)
            % Calculate nnz(take_cols) - nnz(take_rows) more surface normals
            num_add = nnz(take_cols) - nnz(take_rows);
            num_illuminated_row = illuminated * take_cols;

            [~, inds] = sort(num_illuminated_row, "descend");
            for i = inds
                if take_rows(i)
                    continue
                end

                num_add = num_add - 1;
                take_rows(i) = true;

                include_data = illuminated(i, :) & take_cols';
                S(i, :) = L(:, include_data)' \ I(i, include_data)';

                if num_add == 0
                    break
                end
            end
        else
            % Calculate nnz(take_rows) - nnz(take_cols) + 1 light source
            num_add = nnz(take_rows) - nnz(take_cols) + 1;
            num_illuminated_col = take_rows' * illuminated;

            [~, inds] = sort(num_illuminated_col, "descend");
            for i = inds
                if take_cols(i)
                    continue
                end

                num_add = num_add - 1;
                take_cols(i) = true;

                include_data = illuminated(:, i) & take_rows;
                L(:, i) = S(include_data, :) \ I(include_data, i);

                if num_add == 0
                    break
                end
            end
        end
    end
end