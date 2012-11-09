%
%  OneD_Stimuli_SpatialFigure.m
%  SMI
%
%  Created by Bedeho Mender on 06/11/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function OneD_Stimuli_SpatialFigure(trainingStimuliName, testingStimuliName)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Convert stimuli data into scatter format
    [X1 Y1 visualFieldSize eyePositionFieldSize] = convertToXYScatter(trainingStimuliName);
    [X2 Y2 visualFieldSize eyePositionFieldSize] = convertToXYScatter(testingStimuliName);
    
    X{1} = X1;
    X{2} = X2;
    Y{1} = Y1;
    Y{2} = Y2;

    % Setup axis limits
    XLim = [-eyePositionFieldSize/2 eyePositionFieldSize/2];
    YLim = [-visualFieldSize/2 visualFieldSize/2];
    
    % Do scatter plot
    [maxPlot, miniPlot yProjectionAxis, scatterAxis, xProjectionAxis] = scatterPlotWithMarginalHistograms(X, Y, 'XTitle', 'Eye Position (deg)', 'YTitle', 'Receptive Field Location (deg)', 'XLim', XLim, 'YLim', YLim, 'Legends', {'Training', 'Testing'}, 'MarkerSize', 4);
    
    % Save - in testing folder, arbitrary choice
    fname = [base 'Stimuli/' testingStimuliName '/' testingStimuliName '.eps'];
    set(gcf,'renderer','painters');
    print(maxPlot,'-depsc2','-painters',fname);
    
    % Converts object stream to x,y scatter format, flattening out any
    % multiple object structure
    function [X Y visualFieldSize eyePositionFieldSize] = convertToXYScatter(stimuli)
        
        % Load file
        [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Stimuli_Load(stimuli);

        % Cleanup nan
        temp = buffer;
        v = isnan(buffer); % v(:,1) = get logical indexes for all nan rows
        temp(v(:,1),:) = [];  % blank out all these rows

        X = [];
        Y = [];

        % Plot spatial data
        for o = 1:numberOfSimultanousObjects,

            X = [X temp(:,1)];
            Y = [Y temp(:,o + 1)];

        end
        
    end

end

%{
    % Import global variables
    declareGlobalVars();
    
    global base;
    
    colors = {'r', 'b','k','c', 'm', 'y', 'g', 'w'};
    
    % Make figure
    fig = figure();
    
    % Load file
    [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Stimuli_Load(trainingStimuliName);

    % Derived
    leftMostVisualPosition = -visualFieldSize/2;
    rightMostVisualPosition = visualFieldSize/2;
    leftMostEyePosition = -eyePositionFieldSize/2;
    rightMostEyePosition = eyePositionFieldSize/2;     

    % Cleanup nan
    temp = buffer;
    v = isnan(buffer); % v(:,1) = get logical indexes for all nan rows
    temp(v(:,1),:) = [];  % blank out all these rows

    X = [];
    Y = [];

    % Plot spatial data
    for o = 1:numberOfSimultanousObjects,

        if color == '',
            cCode = colors{o};
        else
            cCode = color;
        end

        plot(temp(:,1), temp(:,o + 1) , [cCode markstyle],'LineWidth',linewidth,'MarkerSize', markersize);

        X = [X temp(:,1)];
        Y = [Y temp(:,o + 1)];

        hold on;
    end

    %scatterhist(X,Y);

    % Adjust axis
    axis([leftMostEyePosition rightMostEyePosition leftMostVisualPosition rightMostVisualPosition]);
    
    % SAVE
    fname = [base 'Stimuli/' testingStimuliName '/inputData.eps'];
    set(gcf,'renderer','painters');
    print(fig,'-depsc2','-painters',fname);
%}