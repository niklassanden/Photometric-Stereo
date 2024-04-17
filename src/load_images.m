function images = load_images(name, plot, num_images)
    arguments
        name
        plot = false
        num_images = 20
    end

    images = cell(num_images, 1);

    if plot
        figure;
    end
    for i = 1:num_images
        s = int2str(i);
        if i < 10
            s = "0" + s;
        end
        images{i} = imread("PSData/" + name + "/Objects/Image_" + s + ".png");

        if plot
            subplot(ceil(num_images / 5), 5, i);
            imagesc(images{i});
            colormap gray;
            axis equal;
        end
    end
end