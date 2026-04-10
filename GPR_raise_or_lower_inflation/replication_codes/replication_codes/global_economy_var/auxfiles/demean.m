function c = demean(x)
% Removes the mean of each column of a matrix.

if ndim(x)==1
    c = x - compute_mean(x);
elseif ndim(x)==2
    c = bsxfun(@minus, x, compute_mean(x));
else
    error('descriptive_statistics::demean:: This function is not implemented for arrays with dimension greater than two!')
end
end

function m = compute_mean(x)
    % Helper function for compatibility
    if exist('nanmean', 'file')
        m = nanmean(x);
    else
        m = mean(x, 'omitnan');
    end
end