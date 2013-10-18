
function responseFunction()
    
    inputSigma = 6;
    sigmoidSlope = 0.0625;
    
    ret_max = 30;
    eye_max = 30;
    
    retinalPreferences = -ret_max:2:ret_max; %centerDistance(60*4, 4);
    eyePreferences = -eye_max:2:eye_max; %centerDistance(40*4, 4);
    
    retinalTargets_ticks = -ret_max:15:ret_max;
    eyePreferences_ticks = -eye_max:15:eye_max;

    [retMesh,eyeMesh] = meshgrid(retinalPreferences, eyePreferences);
    
    % first peak
    e = -15
    r = 10
    
    e_first = e;
    e_second = e-5;
    e_third = e+15;
    
    r_2 = 30
    e2 = 15
    
    coeff1 = 1
    coeff2 = 0.8
    
    figure;
    
    %% Sig
    in = exp(-(r - retMesh).^2/(2*inputSigma^2)) .* 1./(1 + exp(sigmoidSlope * (e - eyeMesh)));
    
    %% Lin
    %LIN = (sigmoidSlope*eyeMesh) + e;
    %LIN(LIN < 0) = 0;
    %LIN(LIN > 1) = 1;
    %in = exp(-(r - retMesh).^2/(2*inputSigma^2)) .* LIN;
    
    
    %% Peak
    
    % single peak
    %in = coeff1*exp(-((r - retMesh).^2 + (e - eyeMesh).^2)/(2*inputSigma^2));
    
    % double peak
    %in = coeff1*exp(-((r - retMesh).^2 + (e - eyeMesh).^2)/(2*inputSigma^2)) + coeff2*exp(-((r - retMesh).^2 + (e2 - eyeMesh).^2)/(2*inputSigma^2));
    
    %% Plot
    %{
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
    
    %}
    
    %% New
    
    surf(eyeMesh, retMesh, in,'EdgeColor','none','LineStyle','none','FaceLighting','phong')% 'LineStyle', 'none', 'FaceColor', 'interp');
    hold on
    grid off
    axis off
    colormap cool
        
    %in_line_1 = exp(-((r - retinalPreferences).^2 + (e - e_first).^2)/(2*inputSigma^2)); 
    in_line_1 = exp(-(r - retinalPreferences).^2/(2*inputSigma^2)) .* 1./(1 + exp(sigmoidSlope * (e - e_first)));
    
    
    %in_line_2 = exp(-((r - retinalPreferences).^2 + (e - e_second).^2)/(2*inputSigma^2));
    in_line_2 = exp(-(r - retinalPreferences).^2/(2*inputSigma^2)) .* 1./(1 + exp(sigmoidSlope * (e - e_second)));
    
    %in_line_3 = exp(-((r - retinalPreferences).^2 + (e - e_third).^2)/(2*inputSigma^2));
    in_line_3 = exp(-(r - retinalPreferences).^2/(2*inputSigma^2)) .* 1./(1 + exp(sigmoidSlope * (e - e_third)));
    
    eyeFixed_first = e_first*ones(1,length(in_line_1));
    eyeFixed_second = e_second*ones(1,length(in_line_1));
    eyeFixed_third = e_third*ones(1,length(in_line_1));
    
    plot3(eyeFixed_first, retinalPreferences, in_line_1 , 'LineWidth', 3 ,'Color','r')
    plot3(eyeFixed_second, retinalPreferences, in_line_2 , 'LineWidth', 3 ,'Color','g')
    plot3(eyeFixed_third, retinalPreferences, in_line_3 , 'LineWidth', 3 ,'Color','b')
    
    hZLabel = zlabel('Response');
    hXLabel = xlabel('Eye position (deg)');
    hYLabel = ylabel('Retinal location (deg)');
    
    set([ hZLabel], 'FontSize', 14); % hYLabel hXLabel
    set([gca], 'FontSize', 14);
    
    set(gca,'ZTick',[0 1]);
    set(gca,'XTick', eyePreferences_ticks);
    set(gca,'YTick', retinalTargets_ticks);
    
end