%
%  regionDataPrEyePosition.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Result: (eye_position, object, row, col)

function [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting)

    % Import global variables
    declareGlobalVars();

    % Read header 
    [networkDimensions, nrOfPresentLayers, historyDimensions, neuronOffsets] = loadHistoryHeader(filename);
    
    % Setup vars
    depth                = 1;
    numRegions           = length(networkDimensions);
    numEpochs            = historyDimensions.numEpochs;
    numObjects           = historyDimensions.numObjects;
    numOutputsPrObject   = historyDimensions.numOutputsPrObject;
    objectsPrEyePosition = numObjects / nrOfEyePositionsInTesting;
    
    % Check for compatibility
    if mod(numObjects, nrOfEyePositionsInTesting) ~= 0,
        error(['The number of "objects" is not divisible by nrOfEyePositionsInTesting: o=' num2str(numObjects) ', neps=' num2str(nrOfEyePositionsInTesting)]);
    end
    
    % Get dimensions for this region
    y_dimension = networkDimensions(numRegions).y_dimension;
    x_dimension = networkDimensions(numRegions).x_dimension;
    
    % Check presence of region: Cant see this ever failing
    if ~networkDimensions(numRegions).isPresent,
        error('Last region is not present'); 
    end
    
    % Allocate space
    data = zeros(nrOfEyePositionsInTesting , objectsPrEyePosition, y_dimension, x_dimension);
    
    % Open file
    fileID = fopen(filename);
    
    % Tried using mat2cell stuff in regionHistory, but wasnt worth it.
    % Iterate neurons
    for row=1:y_dimension, % Region row
        for col=1:x_dimension, % Region col
            
            % Get neuron historay
            activity = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, numRegions, depth, row, col, 1); % {object,epoch}->timestep
            
            % Allocate space
            dataAtLastStepPrObject = zeros(1, numObjects);
            for o=1:numObjects,
                dataAtLastStepPrObject(o) = activity{o,numEpochs}(end);
            end
            
            % Restructure to access data on eye position basis
            dataPrEyePosition = reshape(dataAtLastStepPrObject, [objectsPrEyePosition nrOfEyePositionsInTesting]); % (object, eye_position)
            
            % Reshufle dimensions
            dataPrEyePosition = permute(dataPrEyePosition, [2 1]);
            
            % Clean out errors
            dataPrEyePosition(dataPrEyePosition < 0.01) = 0;
            
            % Save result
            data(:,:,row,col) = dataPrEyePosition;
            
        end
    end
    
    % Close file
    fclose(fileID);
    
    %{
        % Import global variables
    declareGlobalVars();
    global floatError;

    % Get dimensions 
    [networkDimensions, nrOfPresentLayers, historyDimensions] = getHistoryDimensions(filename);
    
    % Setup vars
    depth                = 1;
    numRegions           = length(networkDimensions);
    numEpochs            = historyDimensions.numEpochs;
    numObjects           = historyDimensions.numObjects;
    numOutputsPrObject   = historyDimensions.numOutputsPrObject;
    objectsPrEyePosition = numObjects / nrOfEyePositionsInTesting;
    
    % Check for compatibility
    if mod(numObjects, nrOfEyePositionsInTesting) ~= 0,
        error(['The number of "objects" is not divisible by nrOfEyePositionsInTesting: o=' num2str(numObjects) ', neps=' num2str(nrOfEyePositionsInTesting)]);
    end
    
    % Allocate space
    data = cell(numRegions-1,1);
        
    % Iterate regions
    for r = 2:numRegions,

        % Get dimensions for this region
        y_dimension = networkDimensions(r).y_dimension;
        x_dimension = networkDimensions(r).x_dimension;
        isPresent   = networkDimensions(r).isPresent;
        
        if isPresent,
        
            % Pre-process data
            result = regionHistory(filename, r, depth, numEpochs);

            % Get final state of each fixation
            dataAtLastStepPrObject = squeeze(result(numOutputsPrObject, :, numEpochs, :, :)); % (object, row, col)

            % Restructure to access data on eye position basis
            dataPrEyePosition = reshape(dataAtLastStepPrObject, [objectsPrEyePosition nrOfEyePositionsInTesting y_dimension x_dimension]); % (object, eye_position, row, col)

            % Zero out error terms
            dataPrEyePosition(dataPrEyePosition < floatError) = 0; % Cutoff for being designated as silent
            
            % Reshufle dimensions
            dataPrEyePosition = permute(dataPrEyePosition,[2 1 3 4]);
            
            % Save in cell array
            data{r-1,1} = dataPrEyePosition;
        end
        
    end
   
    %}