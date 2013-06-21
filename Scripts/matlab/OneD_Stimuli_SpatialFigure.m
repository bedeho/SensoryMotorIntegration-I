%
%  OneD_Stimuli_SpatialFigure.m
%  SMI
%
%  Created by Bedeho Mender on 06/11/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function OneD_Stimuli_SpatialFigure(trainingStimuliName, testingStimuliName, eyePositionsRecord, allShownTargets)

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
    [maxPlot, miniPlot yProjectionAxis, scatterAxis, xProjectionAxis] = scatterPlotWithMarginalHistograms(X, Y, 'XTitle', 'Eye Position (deg)', 'YTitle', 'Retinal Location (deg)', 'XLim', XLim, 'YLim', YLim, 'Legends', {'Training', 'Testing'}, 'MarkerSize', 4); %  'YLabelOffset', 5
    
    % Save - in testing folder, arbitrary choice
    fname = [base 'Stimuli/' testingStimuliName '/' testingStimuliName '.eps'];
    set(gcf,'renderer','painters');
    print(maxPlot,'-depsc2','-painters',fname);
    
    %pbaspect([201 61 1]);
    
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

    %% Make input encoding overlap
    
    figure;
    
    tmp = bsxfun(@minus, allShownTargets, eyePositionsRecord);
    retlinear = tmp(:);
    eyelinear = eyePositionsRecord(:);
    
    hold on
    
    % Overlap feature
    for i=1:length(retlinear),
        circle2(eyelinear(i), retlinear(i), 19); % Peaked
        %cable(eyelinear(i)-eyePositionFieldSize, eyelinear(i), retlinear(i), 6); % Planar
    end
    
    plot(eyelinear-eyePositionFieldSize, retlinear, '+r', 'MarkerSize', 5);
    plot(eyelinear, retlinear, '+r', 'MarkerSize', 5);
    
    %Planar
    %{
    plot([-eyePositionFieldSize/2 -eyePositionFieldSize/2],[-visualFieldSize/2 visualFieldSize/2],'--b');
    XLim = [-3*eyePositionFieldSize/2 eyePositionFieldSize/2];
    %}
    
    %{
                                % Fix axes ticks
                                width = 2*eyePositionFieldSize;
                                wTicks = 1:(width/2);
                                wdist = 15;
                                wTicks = wTicks(1:wdist:end);
                                eyePositionPreferences = -eyePositionFieldSize/2:1:eyePositionFieldSize/2;
                                wLabels = eyePositionPreferences(1:wdist:end);
                                wCellLabels = cell(1,length(wLabels));
                                for t=1:length(wLabels),
                                  wCellLabels{t} = num2str(wLabels(t));
                                end

                                % ticks and labels
                                for t=2:length(wTicks),
                                  wCellLabels{length(wCellLabels)+1} = num2str(wLabels(t));
                                end

                                set(gca,'XTick',[wTicks (width/2 + wTicks(2:end))]);
                                set(gca,'XTickLabel',wCellLabels);
    
    
    %}
    
    
    
    %XLim = [];
    
    %% Pretty up
    
    hXLabel = xlabel('Eye Position (deg)');
    hYLabel = ylabel('Retinal Location (deg)');
    set(gca, 'FontSize', 14);
    set([hXLabel hYLabel], 'FontSize', 16);
    xlim(XLim);
    ylim(YLim);
    box on
    
    function h = circle2(x,y,r)
        d = r*2;
        px = x-r;
        py = y-r;
        h = rectangle('Position',[px py d d],'Curvature',[1,1]); % 
        daspect([1,1,1])
    end

    function h = cable(left_x,right_x,y,r)
        
        % top bar
        plot([left_x right_x],[(y+r) (y+r)],'k');
        
        % bottom bar
        plot([left_x right_x],[(y-r) (y-r)],'k');
        
        % left curve
        
        v = 90:1:270;
        x_ = r*cosd(v);
        y_ = r*sind(v);
        
        plot(x_+left_x,y_+y,'k');
            
        % right curve
        v = 90:-1:-90;
        x_ = r*cosd(v);
        y_ = r*sind(v);
        
        plot(x_+right_x,y_+y,'k');
        
    end
end
