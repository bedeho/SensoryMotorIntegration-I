%
%  OneDVisualize_TimerFcn.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Draws graphics - TimerFcn callback 

function OneD_Visualize_TimerFcn(obj, event)

    % Exporting
    global OneD_VisualizeTimeObject; % to expose it to make it stoppable in console

    % Importing
    global buffer;
    global lineCounter;             % must be global to be visible across callbacks
    global nrOfObjectsFoundSoFar;
    global timeStep;
    global fig;
    
    global numberOfSimultanousObjects;
    
    global dimensions;
        
    % Update time counter
    OneDVisualizeTimer = (lineCounter - nrOfObjectsFoundSoFar)*timeStep;
    total = uint64(OneDVisualizeTimer * 1000);
    
    fullMin = idivide(total, 60*1000);
    totalWithoutFullMin = mod(total, 60*1000);
    
    fullSec = idivide(totalWithoutFullMin, 1000);
    
    fullMs = mod(totalWithoutFullMin, 1000);
    
    % Read sample file
    if lineCounter <= length(buffer),
        eyePosition = buffer(lineCounter, 1);
    else
        stop(OneD_VisualizeTimeObject);
        return;
    end
    
    % Consume reset
    if ~isnan(eyePosition),

        retinalPositions = buffer(lineCounter, 2:(numberOfSimultanousObjects + 1)); 
         
        disp(['Read: eye =' num2str(eyePosition) ', ret=' num2str(retinalPositions)]);
        
        % Select figure
        figure(fig);
        
        draw();
        
        lineCounter = lineCounter + 1;
  
    else
        lineCounter = lineCounter + 1;
        nrOfObjectsFoundSoFar = nrOfObjectsFoundSoFar + 1;
        disp('object done********************');
        return;
    end
    
    % draw LIP sig*gauss neurons and input space
    function draw()

        %disp('got here');
        
        v = OneD_DG_InputLayer(dimensions, [eyePosition retinalPositions]);
        
        % Clean up so that it is not hidden from us that stimuli is off
        % retina
        v(v < 0.001) = 0;
        sigmoidPositive = squeeze(v(1,:,:));
        sigmoidNegative = squeeze(v(2,:,:));
        
        fullNorm = norm([sigmoidPositive(:); sigmoidNegative(:)])
        
        % + sigmoid
        subplot(3,1,1);
        imagesc(sigmoidPositive/fullNorm);
        daspect([dimensions.eyePositionFieldSize dimensions.visualFieldSize 1]);
        
        tickTitle = [sprintf('%02d', fullMin) ':' sprintf('%02d', fullSec) ':' sprintf('%03d',fullMs)];
        title(tickTitle);
        
        % - sigmoid
        subplot(3,1,2);
        imagesc(sigmoidNegative/fullNorm);
        daspect([dimensions.eyePositionFieldSize dimensions.visualFieldSize 1]);
        
        % input space
        subplot(3,1,3);
        
        % cleanup nan
        temp = buffer;
        v = isnan(buffer); % v(:,1) = get logical indexes for all nan rows
        temp(v(:,1),:) = [];  % blank out all these rows
        
        % plot
        rows = 1:(lineCounter - nrOfObjectsFoundSoFar);
        for o = 1:dimensions.numberOfSimultanousObjects,
            plot(temp(rows, 1), temp(rows ,o + 1) , 'o');
            
            hold on;
        end
        daspect([dimensions.eyePositionFieldSize dimensions.visualFieldSize 1]);
        axis([dimensions.leftMostEyePosition dimensions.rightMostEyePosition dimensions.leftMostVisualPosition dimensions.rightMostVisualPosition]);
        
        %x = eyePosition * ones(1, numberOfSimultanousObjects);
        %y = retinalPositions;
        %plot(x, y,'r*');
        %axis([leftMostEyePosition rightMostEyePosition leftMostVisualPosition rightMostVisualPosition]);
        
        %}
    end

end