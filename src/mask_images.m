function mask = mask_images(images, plot, threshold)
    arguments
        images
        plot = false
        threshold = 40
    end

    sz = size(images{1});
    num_images = length(images);
    mask = zeros(sz);
    for i = 1:num_images
        mask = mask | images{i} > threshold;
    end
    if plot
        figure
        subplot(1, 2, 1);
        imagesc(mask);
        colormap gray;
        axis equal;

        subplot(1, 2, 2);
        imagesc(images{1});
        colormap gray;
        axis equal;
    end
end