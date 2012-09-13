%
%  OneD_Overlay.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Draws graphics - TimerFcn callback 

function OneD_Overlay(trainingStimuliName, testingStimuliName)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    fig = figure();
    
    colors = {'r', 'b','k','c', 'm', 'y', 'g', 'w'};

    % Plot spatial data
    subplot(1,3,1);
    plotStimuli(trainingStimuliName, 'r','.', 1, 6);
    plotStimuli(testingStimuliName, 'b','x', 2, 6);
    
    % Plot temporal eye movement data of training
    subplot(1,3,2);
    plotEyeMovements(trainingStimuliName);

    % Plot temporal eye movement data of testing
    subplot(1,3,3);
    plotEyeMovements(testingStimuliName);
    
    % Save figure
    saveas(fig,[base 'Stimuli/' testingStimuliName '/stim.png'],'png');
    
    % New pretty figure
    
    fig = figure();
    plotStimuli(trainingStimuliName, 'r','o', 1, 6);
    plotStimuli(testingStimuliName, 'b','x', 3, 14);
    
    hTitle = title(''); % title('Input Data');
    hXLabel = xlabel('Eye-position (deg)');
    hYLabel = ylabel('Retinal preference (deg)');
    hLegend = legend('Training','Testing ');
    legend('boxoff');
    
            set( gca                       , ...
                'FontName'   , 'Helvetica' );
            set([hTitle, hXLabel, hYLabel], ...
                'FontName'   , 'AvantGarde');
            set([gca hLegend]             , ...
                'FontSize'   , 14           );
            set([hXLabel, hYLabel]  , ...
                'FontSize'   , 18          );
            set( hTitle                    , ...
                'FontSize'   , 24          , ...
                'FontWeight' , 'bold'      );
            
            set(gca, ...
              'Box'         , 'on'     , ...
              'TickDir'     , 'in'     , ...
              'TickLength'  , [.02 .02] , ...
              'XMinorTick'  , 'off'    , ...
              'LineWidth',  2);
    
    % y-projection
    
    %fig = figure();
    
    % x-projection
    
    
    %function project(name,)
    %end
    
        % New pretty figure
    
    fig = figure();
    plotEyeMovements(trainingStimuliName);
    
    hTitle = title(''); % title('Eye Movement Dynamics');
    hXLabel = xlabel('Time (s)');
    hYLabel = ylabel('Eye-position (deg)');
    %hLegend = legend('Training','Testing ');
    legend('boxoff');
    
            set( gca                       , ...
                'FontName'   , 'Helvetica' );
            set([hTitle, hXLabel, hYLabel], ...
                'FontName'   , 'AvantGarde');
            set([gca ]             , ...
                'FontSize'   , 14           );
            set([hXLabel, hYLabel]  , ...
                'FontSize'   , 18          );
            set( hTitle                    , ...
                'FontSize'   , 24          , ...
                'FontWeight' , 'bold'      );
            
            set(gca, ...
              'Box'         , 'on'     , ...
              'TickDir'     , 'in'     , ...
              'TickLength'  , [.02 .02] , ...
              'XMinorTick'  , 'off'    , ...
              'LineWidth',  2);
          
    % fix t time axis
    % fix legend
    
    function plotStimuli(name, color, markstyle, linewidth, markersize)
        
        % Load file
        [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Load(name);

        % Derived
        leftMostVisualPosition = -visualFieldSize/2;
        rightMostVisualPosition = visualFieldSize/2;
        leftMostEyePosition = -eyePositionFieldSize/2;
        rightMostEyePosition = eyePositionFieldSize/2;     

        % Cleanup nan
        temp = buffer;
        v = isnan(buffer); % v(:,1) = get logical indexes for all nan rows
        temp(v(:,1),:) = [];  % blank out all these rows

        % Plot spatial data
        for o = 1:numberOfSimultanousObjects,
            
            if color == '',
                cCode = colors{o};
            else
                cCode = color;
            end
            
            plot(temp(:,1), temp(:,o + 1) , [cCode markstyle],'LineWidth',linewidth,'MarkerSize', markersize);

            hold on;
        end

        daspect([eyePositionFieldSize visualFieldSize 1]);
        axis([leftMostEyePosition rightMostEyePosition leftMostVisualPosition rightMostVisualPosition]);
    end

    function  plotEyeMovements(name, color)
        %[legends,duration] =
        
        % Load file
        [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Load(name);

        % Derived
        leftMostVisualPosition = -visualFieldSize/2;
        rightMostVisualPosition = visualFieldSize/2;
        leftMostEyePosition = -eyePositionFieldSize/2;
        rightMostEyePosition = eyePositionFieldSize/2;
        
        timeStep = (1/samplingRate);
        
        % Parse out each object
        [objects, minSequenceLength, objectsFound] = OneD_Parse(buffer);

        % Plot movement dynamics of each object
        totalTimePerObject = (minSequenceLength-1) * timeStep;
        
        % Plot spatial data
        linestyle = {'r', 'g', 'b', 'c', 'm', 'y', 'k', 'w'};
        %legends = cell(1,objectsFound);
        for o = 1:objectsFound,
            
            tmp = objects{o};
            yvals = tmp(:,1);
            ticks = (0:(length(yvals)-1)) * timeStep;
            
            % color
            c = mod(o-1,length(linestyle)) + 1;
            
            plot(ticks, yvals , '-b','LineWidth',2);

            
            hold on;
        end

        axis([0 totalTimePerObject leftMostEyePosition rightMostEyePosition]);
        
        title(name);
        
        %duration = timeStep * length(ticks);
    end
end