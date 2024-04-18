function [normal_image, S, L] = rotate_normals(S, L, normal_image, mask, images, plot)
    arguments
        S
        L
        normal_image
        mask
        images
        plot = false
    end

    % Pick z normal
    figure;
    for i = 1:3
        subplot(1,3,i)
        imshow(images{i});
    end
    title("Pick point first with normal towards camera then with normal towards right, then downwards")
    [x, y] = ginput(3);
    close(gcf);
    x = round(x);
    y = round(y);

    n = 3;
    mean_normal = normalize(squeeze(sum(normal_image(y(1)-n:y(1)+n, x(1)-n:x(1)+n, :), [1 2])), "norm");
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
    right_normal = normalize(squeeze(sum(normal_image(y(2)-n:y(2)+n, x(2)-n:x(2)+n, 1:2), [1 2])), "norm");
    if any(isnan(right_normal))
        error("Pick again!");
    end

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

    down_normal = squeeze(sum(normal_image(y(3)-n:y(3)+n, x(3)-n:x(3)+n, 1:2), [1 2]));
    if down_normal(2) < 0
        S = S * diag([1, -1, 1]);
        L = diag([1, -1, 1]) * L;
    end

    normal_image = get_normal_image(S, mask);
    if plot
        subplot(1, 3, 3)
        imagesc(normal_image)
    end
end