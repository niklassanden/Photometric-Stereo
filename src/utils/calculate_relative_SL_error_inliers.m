function error = calculate_relative_SL_error_inliers(S, L, I, illuminated)
    error = norm(illuminated .* (S * L - I), 'fro') / norm(illuminated .* I, "fro");
end