
function responseFunction()

    retinalTargets = centerN(80, 21);
    eyeTargets = centerN(40, 21);
    
    inputSigma = 18;
    sigmoidSlope = 0.1;
    
    retinalPreferences = centerDistance(60*4, 4);
    eyePreferences = centerDistance(40*4, 4);

    [retMesh,eyeMesh] = meshgrid(retinalPreferences, eyePreferences);
    
    e = 5
    r = 7
    
    % Sig
    in = exp(-(r - retMesh).^2/(2*inputSigma^2)) .* 1./(1 + exp(sigmoidSlope * (e - eyeMesh)));
    
    % Lin
    %e = (0.1*eyeMesh + 1);
    %e(e < 0) = 0
    %in = exp(-(r - retMesh).^2/(2*inputSigma^2)) .* e;
    %in = in/max(max(in));
    
    %Peak
    %in = exp(-((r - retMesh).^2 + (e - eyeMesh).^2)/(2*inputSigma^2));

    surf(retMesh,eyeMesh,in);
    
    zlabel('Response');
    ylabel('Eye Position (deg)');
    xlabel('Retinal Position (deg)');
    
    axis tight;
    axis off
    shading interp
    
    %{
    set(gca, ...
      'TickDir'     , 'in'     , ...
      'TickLength'  , [.02 .02] , ...
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'XTick'       , retinalTargets);
    %}
end