
function v = centerN2(width, n)

    dist = floor(width/n);
    
    if mod(dist,2) == 1,
        dist = dist + 1;
    end

    v = (1:n)*dist;
    v = v - (v(1) + v(end)) / 2;
    
        
