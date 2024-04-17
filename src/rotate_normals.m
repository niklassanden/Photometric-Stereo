function [normal_image, S, L] = rotate_normals(S, L, normal_image, mask, plot)
    arguments
        S
        L
        normal_image
        mask
        plot = false
    end

    % Fix z axis
    % ------------------------
    mask_border = conv2(mask, ones(3), "same");
    mask_border = (mask_border < 9) & mask;
    if plot
        figure;
        imagesc(mask_border);
    end
    % DLT
    M = normal_image(cat(3, mask_border, mask_border, mask_border));
    M = reshape(M, [nnz(mask_border), 3]);
    [~, ~, V] = svd(M);
    R3 = V(:, 3);
    if sum(S * R3, "all") < 0
        R3 = -R3;
    end

    % Make R
    R2 = cross(R3, [1;0;0]);
    if norm(R2) < 1e-3
        R2 = cross(R3, [0;1;0]);
    end
    R2 = normalize(R2, "norm");
    R1 = cross(R2, R3);

    R = [R1, R2, R3];
    S = S * R;
    L = R' * L;
    %sum(abs(M(:,end).^2))
    %sum(abs(M*R3).^2)
    %R

    if plot
        figure
        subplot(1, 3, 1)
        imagesc(normal_image);
    end
    normal_image = get_normal_image(S, mask);
    if plot
        subplot(1, 3, 2)
        imagesc(normal_image)
    end

    % Fix x and y axis
    % ------------------------
    rightmost_column = find(sum(mask_border, 1), 1, "last");
    sections = bwlabel(mask_border(:, rightmost_column), 4);
    unique_sections = unique(sections);
    section_sizes = histc(sections, unique_sections);
    [~, max_section] = max(section_sizes);
    component_indices = find(sections == max_section);
    center = round(mean(component_indices));

    right_normal = normalize(reshape(normal_image(center, rightmost_column, 1:2), [2 1]), "norm");
    radians = 0;
    if right_normal(1) < 0
        radians = pi;
        right_normal = -right_normal;
    end
    radians = radians - asin(right_normal(2));

    R = [
        cos(-radians), -sin(-radians), 0
        sin(-radians), cos(-radians), 0
        0, 0, 1
    ];
    S = S * R;
    L = R' * L;

    normal_image = get_normal_image(S, mask);
    if plot
        subplot(1, 3, 3)
        imagesc(normal_image)
    end
end