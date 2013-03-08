
function responseFunction()

    figure;

    retinalTargets = centerN(80, 21);
    eyeTargets = centerN(40, 21);
    
    inputSigma = 10;
    sigmoidSlope = 0.0625;
    
    retinalPreferences = -50:4:50; %centerDistance(60*4, 4);
    eyePreferences = -50:4:50; %centerDistance(40*4, 4);

    [retMesh,eyeMesh] = meshgrid(retinalPreferences, eyePreferences);
    
    e = -20
    e2 = 15
    r = 40
    coeff1 = 1
    coeff2 = 0.8
    
    %% Sig
    %in = exp(-(r - retMesh).^2/(2*inputSigma^2)) .* 1./(1 + exp(sigmoidSlope * (e - eyeMesh)));
    
    %% Lin
    %LIN = (sigmoidSlope*eyeMesh) + e;
    %LIN(LIN < 0) = 0;
    %LIN(LIN > 1) = 1;
    %in = exp(-(r - retMesh).^2/(2*inputSigma^2)) .* LIN;
    
    
    %% Peak
    
    % single peak
    %in = coeff1*exp(-((r - retMesh).^2 + (e - eyeMesh).^2)/(2*inputSigma^2));
    
    % double peak
    in = coeff1*exp(-((r - retMesh).^2 + (e - eyeMesh).^2)/(2*inputSigma^2)) + coeff2*exp(-((r - retMesh).^2 + (e2 - eyeMesh).^2)/(2*inputSigma^2));
    
    %% Plot
    meshc(retMesh,eyeMesh,in);
    
    % Move contours:
    % http://www.mathworks.co.uk/support/solutions/en/data/1-17AF2/index.html?product=SL&solution=1-17AF2
    new_level = -3;
    
    % Get the handle to each patch object
    h = findobj('type','patch');
    
    % Create a loop to change the height of each contour
    zd = get(h,'ZData');
    for i = 1:length(zd)
    set(h(i),'ZData',new_level*ones(length(zd{i}),1))
    end
    
    zlabel('Response');
    ylabel('Eye Position (deg)');
    xlabel('Retinal Position (deg)');
    
    %pbaspect([201 61 4.5])
    
    %axis([-100 100 -30 30 -3 1.5]);
    
    %axis off

    
    %{
    set(gca, ...
      'TickDir'     , 'in'     , ...
      'TickLength'  , [.02 .02] , ...
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'XTick'       , retinalTargets);
    %}
end