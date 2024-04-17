function [depths, grads] = integrate_surface(normal_image, mask)
    pixel_count = numel(normal_image(:,:,1));
    sz = size(normal_image(:,:,1));

    grads = -normal_image(:,:,1:2) ./ (normal_image(:,:,3) + (normal_image(:,:,3) == 0));
    grads = min(max(grads, -10), 10);

    to_ind = @(r, c) sub2ind(sz, r, c);

    rows = [];
    cols = [];
    values = [];
    b = [];
    eq = 1;
    dirs = {[0 -1], [-1 0], [0 1], [1 0]};
    dims = {1, 2, 1, 2};
    signs = {1, 1, -1, -1};
    for r = 1:sz(1)
        for c = 1:sz(2)
            for i = 1:length(dirs)
                if r+dirs{i}(1) >= 1 && r+dirs{i}(1) <= sz(1) && c+dirs{i}(2) >= 1 && c+dirs{i}(2) <= sz(2)
                    rows(end+1) = eq;
                    cols(end+1) = to_ind(r, c);
                    values(end+1) = 1;

                    rows(end+1) = eq;
                    cols(end+1) = to_ind(r+dirs{i}(1), c+dirs{i}(2));
                    values(end+1) = -1;

                    b(end+1) = signs{i} * grads(r+dirs{i}(1), c+dirs{i}(2), dims{i});

                    eq = eq + 1;
                end
            end
        end
    end
    rows(end+1) = eq;
    cols(end+1) = 1;
    values(end+1) = 1;
    b(end+1) = 0;
    eq = eq + 1;

    A = sparse(rows, cols, values, eq-1, pixel_count);
    depths = A \ b';
    depths = reshape(depths, sz);
    depths = depths - min(depths .* mask, [], "all");
    depths(~mask) = NaN;
end