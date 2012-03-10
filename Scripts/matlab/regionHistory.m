%
%  regionHistory.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  maxEpoch (optional): largest epoch you are interested in
%  
%  Activity history of region/depth: 4-d array (timestep, object, epoch, row, col) 

function [activity] = regionHistory(filename, region, depth, maxEpoch)

    % Import global variables
    global SOURCE_PLATFORM_FLOAT;
    
    % Load header
    [networkDimensions, nrOfPresentLayers, historyDimensions, neuronOffsets] = loadHistoryHeader(filename);
    
    % Validate input
    validateNeuron('regionHistory.m', networkDimensions, region, depth);
    
    % Process input
    if nargin < 7,
        maxEpoch = historyDimensions.numEpochs;
    else
        if maxEpoch < 1 || maxEpoch > historyDimensions.numEpochs,
            error([file ' error: epoch ' num2str(maxEpoch) ' does not exist'])
        end
    end
    
    y_dimension = networkDimensions(region).y_dimension;
    x_dimension = networkDimensions(region).x_dimension;
    
    % Open file
    fileID = fopen(filename);
    
    % When we are looking for full epoch history, we can get it all in one chunk
    if maxEpoch == historyDimensions.numEpochs,
        
        % Seek to offset of neuron region.(depth,1,1)'s data stream
        fseek(fileID, neuronOffsets{region}(1, 1, depth).offset, 'bof');

        % Read into buffer
        streamSize = y_dimension * x_dimension * maxEpoch * historyDimensions.epochSize;
        [buffer count] = fread(fileID, streamSize, SOURCE_PLATFORM_FLOAT);
        
        if count ~= streamSize,
            error(['Read ' num2str(count) ' bytes, ' num2str(streamSize) ' expected ']);
        end

        activity = reshape(buffer, [historyDimensions.numOutputsPrObject historyDimensions.numObjects maxEpoch y_dimension x_dimension]);
        
        % Because file is saved in row major,
        % and reshape fills in buffer in column major,
        % we have to permute the last two dimensions (row,col)
        activity = permute(activity, [1 2 3 5 4]);
    else
        %When we are looking for partial epoch history, then we have to
        %seek betweene neurons, so we just use neuronHistory() routine
        
        activity = zeros(historyDimensions.numOutputsPrObject, historyDimensions.numObjects, maxEpoch, y_dimension, x_dimension);
        
        for row=1:y_dimension,
            for col=1:x_dimension,
                activity(:, :, :, :, row, col) = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch);
            end
        end
    end
    
    % Close file
    fclose(fileID);