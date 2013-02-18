%
%  OneD_Stimuli_Visualize_TimerFcn.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Draws graphics - TimerFcn callback 

function OneD_Stimuli_Visualize_TimerFcn(obj, event, numberOfSimultanousTargets, visualPreferences, eyePositionPreferences, gaussianSigma, sigmoidSlope, visualFieldSize, eyePositionFieldSize, timeStep)

    % Exporting
    global OneD_Stimuli_VisualizeTimeObject; % to expose it to make it stoppable in console

    % Importing
    global buffer;
    global lineCounter;             % must be global to be visible across callbacks
    global nrOfObjectsFoundSoFar;
    global fig;
    global lastEyePosition;
    global lastRetinalPositions;
    
    % Update time counter
    OneDVisualizeTimer = (lineCounter - nrOfObjectsFoundSoFar)*timeStep;
    total = uint64(OneDVisualizeTimer * 1000);
    
    fullMin = idivide(total, uint64(60*1000));
    totalWithoutFullMin = mod(total, 60*1000);
    
    fullSec = idivide(totalWithoutFullMin, uint64(1000));
    
    fullMs = mod(totalWithoutFullMin, 1000);
    
    % Read sample file
    if lineCounter <= length(buffer),
        eyePosition = buffer(lineCounter, 1);
    else
        stop(OneD_Stimuli_VisualizeTimeObject);
        return;
    end
    
    % Consume reset
    if ~isnan(eyePosition),

        retinalPositions = buffer(lineCounter, 2:(numberOfSimultanousTargets + 1)); 
         
        disp(['eye =' num2str(eyePosition) ', ret=' num2str(retinalPositions)]);
        
        if lineCounter == 1 || lastEyePosition ~= eyePosition || any(lastRetinalPositions ~= retinalPositions),

            % Select figure
            figure(fig);

            draw();
        
        end
        
        lastEyePosition = eyePosition;
        lastRetinalPositions = retinalPositions;

        lineCounter = lineCounter + 1;
  
    else
        lineCounter = lineCounter + 1;
        nrOfObjectsFoundSoFar = nrOfObjectsFoundSoFar + 1;
        disp('object done********************');
        return;
    end
    
    % draw LIP sig*gauss neurons and input space
    function draw()
        

        v = OneD_Stimuli_InputLayer([eyePosition retinalPositions], visualPreferences, eyePositionPreferences, gaussianSigma, sigmoidSlope);
        
        % Clean up so that it is not hidden from us that stimuli is off
        % retina
        %v(v < 0.001) = 0;
        sigmoidPositive = squeeze(v(1,:,:));
        sigmoidNegative = squeeze(v(2,:,:));
        
        disp(['Total: ' num2str(sum(sum(sigmoidPositive)))]);
        
        %fullNorm = norm([sigmoidPositive(:); sigmoidNegative(:)]);
        
        % + sigmoid
        subplot(4,1,1);
        im = imagesc(sigmoidPositive);%/fullNorm
        pbaspect([eyePositionFieldSize visualFieldSize 1]);
        
        tickTitle = [sprintf('%02d', fullMin) ':' sprintf('%02d', fullSec) ':' sprintf('%03d',fullMs)];
        title(tickTitle);
        
        set(im, 'ButtonDownFcn', @responseCallBack); % Setup callback
        
        % - sigmoid
        subplot(4,1,2);
        imagesc(sigmoidNegative); % /fullNorm
        pbaspect([eyePositionFieldSize visualFieldSize 1]);
        
        
        %% input space
        subplot(4,1,3);
        
        plot(eyePosition*ones(numberOfSimultanousTargets), retinalPositions , 'o');
        
        pbaspect([eyePositionFieldSize visualFieldSize 1]);
        axis([-eyePositionFieldSize/2 eyePositionFieldSize/2 -visualFieldSize/2 visualFieldSize/2]);
        title('Present input');
        
        set(gca, 'ButtonDownFcn', @responseCallBack); % Setup callback
        
        %% input space
        subplot(4,1,4);
        
        % cleanup nan
        temp = buffer;
        v = isnan(buffer); % v(:,1) = get logical indexes for all nan rows
        temp(v(:,1),:) = [];  % blank out all these rows
        
        % plot
        %cla
        rows = 1:(lineCounter - nrOfObjectsFoundSoFar);
        for o = 1:numberOfSimultanousTargets,
            plot(temp(rows, 1), temp(rows ,o + 1) , 'o');
            
            hold on;
        end
        pbaspect([eyePositionFieldSize visualFieldSize 1]);
        axis([-eyePositionFieldSize/2 eyePositionFieldSize/2 -visualFieldSize/2 visualFieldSize/2]);
        title('History input');
    end

    % Callback - kill visualizer
    function responseCallBack(varargin)
        
        % single left  click => 'SelectionType' = 'normal'
        % single right click => 'SelectionType' = 'alt'
        % double right click => 'SelectionType' = 'open'
        clickType = get(gcf,'SelectionType')
        
        stop();
        
        disp('You stopped the visualizer');

    end

end