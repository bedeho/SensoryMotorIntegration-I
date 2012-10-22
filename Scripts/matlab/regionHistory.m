%
%  regionHistory.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  OUTPUT: 
%  NEVER IMPLEMENTED: activity = Activity history of region/depth [2D cell->4D array]:  {epoch, object} -> (timestep, epoch, row, col)

% OUTPUT:
%  Activity history of region/depth: 4-d array (timestep, object, epoch, row, col) 
function [activity] = regionHistory_EQUALOBJECTLENGTH(filename, region, depth, maxEpoch)

    % Import global variables
    global SOURCE_PLATFORM_FLOAT;
    
    % Load header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(filename);
    
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
    
    % Check that indeed all objects have same output
    numOutputsPrObject = historyDimensions.numOutputsPrObject;
    
    if(numOutputsPrObject(1)*ones(1,historyDimensions.numObjects) ~= numOutputsPrObject),
        error('All objects must have same number of outputs.');
    elseif(maxEpoch == historyDimensions.numEpochs),     % When we are looking for full epoch history, we can get it all in one chunk
        error('All epochs must be read simultanously.');
    end
    
    y_dimension = networkDimensions(region).y_dimension;
    x_dimension = networkDimensions(region).x_dimension;
    
    % Open file
    fileID = fopen(filename);
    
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

    
    % Close file
    fclose(fileID);
end