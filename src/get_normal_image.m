function normal_image = get_normal_image(S, mask)
    sz = size(mask);
    normals = normalize(S, 2, "norm");
    normal_image = zeros(sz(1), sz(2), 3);
    mask_3d = cat(3, mask, mask, mask);
    normal_image(mask_3d) = normals;
end