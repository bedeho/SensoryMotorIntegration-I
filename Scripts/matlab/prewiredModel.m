%
%  prewiredModel.m
%  SMI
%
%  Created by Bedeho Mender on 08/11/12.
%  Copyright 2012 OFTNAI. All rights reserved.''
%
%  Purpose: Generate prewired model, both PO and LIP
%

function prewiredModel(filename)

    % Stimuli/Model Parameters
    q                                   = 0.7; % targetRangeProportionOfVisualField
    visualFieldSize                     = 200; % Entire visual field (rougly 100 per eye), (deg)
    eyePositionFieldSize                = (1-q)*visualFieldSize; % (1-q)*visualFieldSize OR equivalently (visualFieldSize/2 - targetVisualRange/2)
    targetVisualRange                   = visualFieldSize * q;
    %targetEyePositionRange              = 0.8*eyePositionFieldSize; %eyePositionFieldSize;
    visualPreferenceDistance            = 1;
    eyePositionPrefrerenceDistance      = 1;
    targetSpacing                       = 17; % (deg)
    inputLayerSigma                     = 3;
    
    % Setup random number generator
    seed = 3;
    rng(seed, 'twister');
    
    % Init variables
    visualPreferences                   = fliplr(centerDistance(visualFieldSize, visualPreferenceDistance));
    eyePositionPreferences              = centerDistance(eyePositionFieldSize, eyePositionPrefrerenceDistance);
    nrOfVisualPreferences               = length(visualPreferences);
    nrOfEyePositionPrefrerence          = length(eyePositionPreferences);
    targets                             = centerDistance(targetVisualRange, targetSpacing);
    numTargetPositions                  = length(targets);
    
    % Output layer
    inputLayerDepth                     = 1; % 1 = PO, 2 = LIP
    %fanInPercentage                     = 0.30; % [0 1)
    desiredFanIn                        = 367; %fanInPercentage*(nrOfVisualPreferences*nrOfEyePositionPrefrerence*inputLayerDepth);
    
    numRegions                          = 2;
    dim                                 = 30;
    verticalDimension                   = dim;
    horizontalDimension                 = dim;
    
    % Allocate space to keep network,
    % online generation is not possible since there is a header,
    % numberOfAFferentSynapses varies across neurons
    synapseBuffer = cell(verticalDimension,horizontalDimension);
    
    coeff = 0.3;
    activeNeurons = coeff*(verticalDimension * horizontalDimension);
    
    % Info buffer
    allocatedHeadPositions = zeros(verticalDimension, horizontalDimension);
    
    % Open file
    fileID = fopen(filename,'w+');

    % Write number of regions
    fwrite(fileID, numRegions, 'uint16');
    
    % Write input layer dimensions (7a?)
    fwrite(fileID, [nrOfVisualPreferences nrOfEyePositionPrefrerence inputLayerDepth], 'uint16');
    
    % Write output layer dimensions (LIP), dummy info really
    fwrite(fileID, [verticalDimension horizontalDimension 1], 'uint16');
    
    % Write neuron spesific specs
    for row=1:verticalDimension,
        
        disp([num2str(row*100/verticalDimension) '%']);
        
        for col=1:horizontalDimension,

            % Pick target
            target = targets(randi(numTargetPositions,1,1));
            
            % Setup neuron variables
            numberOfAfferentSynapses = 0;
            
            % Save what was picked
            allocatedHeadPositions(row,col) = target;
            
            % Generated figure
            %{
            figure();
            title(['Row,Col =' num2str(row) ',' num2str(col)])
            mat1 = zeros(dimensions.nrOfVisualPreferences,dimensions.nrOfEyePositionPrefrerence);
            mat2 = zeros(dimensions.nrOfVisualPreferences,dimensions.nrOfEyePositionPrefrerence);
            %}
            
            % FORGOT TO CLEAR <== damn this bug
            clearvars synapses
            
            % Connectivity matrix
            isConnected = zeros(inputLayerDepth, nrOfVisualPreferences, nrOfEyePositionPrefrerence);
            
            % Connect to presynaptic sources
            while(numberOfAfferentSynapses < desiredFanIn)
                
                % Generate random presynaptic neuron
                d   = randi(inputLayerDepth);
                ret = randi(nrOfVisualPreferences);
                eye = randi(nrOfEyePositionPrefrerence);
                
                % Deduce preference
                retPref = visualPreferences(ret);
                eyePref = eyePositionPreferences(eye);
                
                % Check if it is inside diagonal
                [connect, weight] = doConnect2(eyePref, retPref, target, d, inputLayerDepth);
                
                % Check that we are not already connected to it
                if(~isConnected(d,ret,eye) && connect),
                    
                    % Increase number of synapses
                    numberOfAfferentSynapses = numberOfAfferentSynapses + 1;

                    % Save synapse
                    synapses(:,numberOfAfferentSynapses) = [0 (d-1) (ret-1) (eye-1) weight];
                    
                    % Mark as connected
                    isConnected(d,ret,eye) = 1;
                    
                end
                
            end
            
            % FIGURE
            %{
                subplot(1,2,1);
                imagesc(mat1);
                colorbar
                subplot(1,2,2);
                imagesc(mat2);
                colorbar
            %}
            
            % Normalize weight vector
            %synapses(5,:) = synapses(5,:)/norm(synapses(5,:));
            
            % Save synapses
            synapseBuffer{row,col} = synapses;
            
            % Write out for header
            fwrite(fileID, numberOfAfferentSynapses, 'uint16');
            
            % Output neuron
            %disp(['Row,Col =' num2str(row) ',' num2str(col) ': ' num2str(numberOfAfferentSynapses)])
            
        end
    end
    
    % Synapse i:
    % synapses(1,i) = regionNr
    % synapses(2,i) = depth
    % synapses(3,i) = row
    % synapses(4,i) = col
    % synapses(5,i) = weight
   
    % Write out actual network
    for row=1:verticalDimension,
        for col=1:horizontalDimension,
            
            % Get synapses
            afferents = synapseBuffer{row,col};
            
            % Iterate afferent synapses and dump
            for s=1:length(afferents),
                
               % afferents(:,s)
                
               % Write synapse
               fwrite(fileID, afferents(1:4,s), 'uint16');
               fwrite(fileID, afferents(5,s), 'float32');
            end
        end
    end
    
   fclose(fileID);
   
   % Save buffer
   [pathstr, name, ext] = fileparts(filename);
   save([pathstr '/info.mat'], 'allocatedHeadPositions');
   
   function [connect,weight] = doConnect2(eyePref, retPref, target, d, inputLayerDepth)

        if inputLayerDepth == 1, % PEAKED

            connectWindow = 2;
            cond1 = eyePref+retPref <= target+connectWindow*inputLayerSigma; % isBelowUpperBound
            cond2 = eyePref+retPref >= target-connectWindow*inputLayerSigma; % isAboveLowerBound

            % Find distane to head-centeredness diagonal
            % smallest distance between ax + bx + c = 0 and x0,y0 is:
            %
            % abs(ax_0 + b_y0 + c) / norm([a b])
            %
            % where
            % x = e (eye position
            % y = r (retinal position)
            % c = -target (head position)
            x0 = eyePref;
            y0 = retPref;
            a = 1;
            b = 1;
            c = -target;

            distance = abs(a*x0 + b*y0 + c) / norm([a b]);

            weight = exp(-(distance^2)/(2*inputLayerSigma^2)); 
            
        elseif inputLayerDepth == 2 % SIGMOID

            cond1 = (eyePref+retPref <= target && d==1); % isToLeftOfTargets
            cond2 = (eyePref+retPref >= target && d==2); % isAboveLowerBound
            weight = rand([1 1]); % Get random weight
        end
        
        % Make final stochastic decision
        connect = cond1 && cond2;

    end

end

