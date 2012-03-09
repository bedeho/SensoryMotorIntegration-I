%
%  neuronHistory.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Activity history of region: 3-d matrix (timestep, object, epoch)

function [activity] = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch)

    % Import global variables
    global SOURCE_PLATFORM_FLOAT;

    % Validate input
    validateNeuron('neuronHistory.m', networkDimensions, region, depth, row, col);
      
    if maxEpoch < 1 || maxEpoch > historyDimensions.numEpochs,
        error([file ' error: epoch ' num2str(maxEpoch) ' does not exist'])
    end
    
    % Seek to offset of neuron region.(depth,i,j)'s data stream
    fseek(fileID, neuronOffsets{region}(row, col, depth).offset, 'bof');
    
    % Read into buffer
    streamSize = maxEpoch * historyDimensions.epochSize;
    [buffer count] = fread(fileID, streamSize, SOURCE_PLATFORM_FLOAT);
    
    if count ~= streamSize,
        error(['Read ' num2str(count) ' bytes, ' num2str(streamSize) ' expected ']);
    end
    
    % Make history array
    activity = reshape(buffer, [historyDimensions.numOutputsPrObject historyDimensions.numObjects maxEpoch]);