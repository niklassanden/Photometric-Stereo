function [normal_image, S, L] = rotate_normals(S, L, normal_image, mask, image, plot)
    arguments
        S
        L
        normal_image
        mask
        image
        plot = false
    end

    % Pick z normal
    figure;
    imshow(image);
    [x, y] = ginput(1);
    close(gcf);
    x = round(x);
    y = round(y);

    n = 3;
    mean_normal = normalize(squeeze(sum(normal_image(y-n:y+n, x-n:x+n, :), [1 2])), "norm");
    if any(isnan(mean_normal))
        error("Pick again!");
    end

    axis = cross([0; 0; 1], mean_normal);
    angle = acos(dot([0; 0; 1], mean_normal));
    skew = [0 -axis(3) axis(2); axis(3) 0 -axis(1); -axis(2) axis(1) 0];
    R = eye(3) + skew * sin(angle) + skew^2 * (1 - cos(angle))';
    S = S * R;
    L = R' * L;

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
    mask_border = conv2(mask, ones(3), "same");
    mask_border = (mask_border < 9) & mask;
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