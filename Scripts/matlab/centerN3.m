
function v = centerN3(stepsize, n)


    v = 1:stepsize:(stepsize*n);
    v = v - (v(1) + v(end)) / 2;