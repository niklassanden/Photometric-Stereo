addpath('src')
addpath('src/utils')

images = load_images("cat", true);
sz = size(images{1});
num_images = length(images);

mask = mask_images(images, true);

% Consider moving to a function
p = nnz(mask);
I = zeros(p, num_images);
for i = 1:num_images
    I(:,i) = images{i}(mask);
end

[S_hat, L_hat] = primitive_solution(I);
fprintf("Primitive solution error: %f\n", calculate_relative_SL_error(S_hat, L_hat, I));

[S, L] = upgrade_constant_albedo(S_hat, L_hat);

normal_image = get_normal_image(S, mask);

[normal_image, S, L] = rotate_normals(S, L, normal_image, mask, true);

[depths, grads] = integrate_surface(normal_image, mask);

% Visualize result
figure
imagesc(depths);
colorbar

figure
surf(depths(1:2:end, 1:2:end));
colorbar;
axis equal;