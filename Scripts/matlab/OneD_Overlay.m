%
%  OneD_Overlay.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Draws graphics - TimerFcn callback 

function OneD_Overlay(trainingStimuliName, testingStimuliName)

    figure();

    % Plot spatial data
    subplot(1,3,1);
    plotStimuli(trainingStimuliName, 'ro');
    plotStimuli(testingStimuliName, 'bx');
    
    % Plot temporal eye movement data of training
    subplot(1,3,2);
    plotEyeMovements(trainingStimuliName);

    % Plot temporal eye movement data of testing
    subplot(1,3,3);
    plotEyeMovements(testingStimuliName);
    
    function plotStimuli(name, color)
        
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
            plot(temp(:,1), temp(:,o + 1) , color);

            hold on;
        end

        daspect([eyePositionFieldSize visualFieldSize 1]);
        axis([leftMostEyePosition rightMostEyePosition leftMostVisualPosition rightMostVisualPosition]);
    end

    function plotEyeMovements(name, color)
        
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
        markerSpecifiers = {'r+', 'g.', 'bx', 'cs', 'md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','r+', 'g.', 'bx', 'cs', 'md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','r+', 'g.', 'bx', 'cs', 'md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','r+', 'g.', 'bx', 'cs', 'md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','r+', 'g.', 'bx', 'cs', 'md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','r+', 'g.', 'bx', 'cs', 'md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx','md', 'y^', 'kv', 'w>', 'r+', 'g.', 'bx'};
        for o = 1:objectsFound,
            
            tmp = objects{o};
            plot(0:timeStep:totalTimePerObject, tmp(:,1) , markerSpecifiers{o});

            hold on;
        end

        axis([0 totalTimePerObject leftMostEyePosition rightMostEyePosition]);
        
        title(name);
    end
end