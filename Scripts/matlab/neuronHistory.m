%
%  neuronHistory.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  OUTPUT: 
%  * activity = Activity history of region [2D cell -> 1D array]: {object, epoch}->timestep

function [activity] = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch)

    % Import global variables
    global SOURCE_PLATFORM_FLOAT;

    % Validate input
    validateNeuron('neuronHistory.m', networkDimensions, region, depth, row, col);
    
    if nargin < 9,
        maxEpoch = historyDimensions.numEpochs;
    elseif maxEpoch < 1 || maxEpoch > historyDimensions.numEpochs,
        error([file ' error: epoch ' num2str(maxEpoch) ' does not exist'])
    end
    
    % Seek to offset of neuron region.(depth,i,j)'s data stream
    status = fseek(fileID, neuronOffsets{region}(row, col, depth).offset, 'bof');
    
    if status ~= 0,
        error('Was unable to seek to desired neuron offset.');
    end
    
    % Read ENTIRE stream into buffer
    itemsToRead = historyDimensions.epochSize*maxEpoch;
    [buffer count] = fread(fileID, itemsToRead, SOURCE_PLATFORM_FLOAT);

    if count ~= itemsToRead,
        error(['Read ' num2str(count) ' items, ' num2str(itemsToRead) ' expected ']);
    end
    
    if any(isnan(buffer)),
        error('NaN found');
    end
    
    % Reshape stream so that it can be partitioned
    reshapedBuffer = reshape(buffer,[historyDimensions.epochSize maxEpoch]);
    
    % Partition stream into cells
    activity = mat2cell(reshapedBuffer, historyDimensions.numOutputsPrObject, ones(1,maxEpoch)); % historyDimensions.epochSize*ones(1,maxEpoch)