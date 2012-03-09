
function [v] = centerN(width, n)

    if n < 2,
        error('inappropriate n passed to centeredSplit...');
    end
    
    v = -width/2:width/n:width/2;
    v = v(1:(end - 1)); % we want n elements, not n+1
    v = v - (v(1) + v(end)) / 2; % shift approprite amount in the right direction to center