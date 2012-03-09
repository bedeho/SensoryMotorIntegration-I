%
%  regionDataPrEyePosition.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Result: (object, eye_position, row, col, region)

function [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting)

    % Import global variables
    declareGlobalVars();
    global floatError;

    % Get dimensions
    [networkDimensions, historyDimensions] = getHistoryDimensions(filename);
    
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
        
        % Pre-process data
        result = regionHistory(filename, r, depth, numEpochs);

        % Get final state of each fixation
        dataAtLastStepPrObject = squeeze(result(numOutputsPrObject, :, numEpochs, :, :)); % (object, row, col)

        % Restructure to access data on eye position basis
        dataPrEyePosition = reshape(dataAtLastStepPrObject, [objectsPrEyePosition nrOfEyePositionsInTesting y_dimension x_dimension]); % (object, eye_position, row, col)

        % Zero out error terms
        dataPrEyePosition(dataPrEyePosition < floatError) = 0; % Cutoff for being designated as silent
        
        % Save in cell array
        data{r-1,1} = dataPrEyePosition;
        
    end
   