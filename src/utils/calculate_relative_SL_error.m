function error = calculate_relative_SL_error(S, L, I)
    error = norm(S * L - I, 'fro') / norm(I, "fro");
end