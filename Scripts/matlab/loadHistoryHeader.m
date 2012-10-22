%
%  loadHistoryHeader.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: 
%  * Load header of history file
%
%  Input:
%  * filname
%
%  OUTPUT:
%  * networkDimensions: struct array (dimension,depth) of regions (including V1)
%  * historyDimensions: struct {numEpochs,numObjects, numOutputsPrObject array, epochSize, streamSize}

function [networkDimensions, nrOfPresentLayers, historyDimensions, neuronOffsets] = loadHistoryHeader(filename)

    % Import global variables
    declareGlobalVars();
    
    global SOURCE_PLATFORM_USHORT;
    global SOURCE_PLATFORM_USHORT_SIZE;
    global SOURCE_PLATFORM_FLOAT_SIZE;
    global SOURCE_PLATFORM_LONG_LONG_UINT;
    global SOURCE_PLATFORM_LONG_LONG_UINT_SIZE;

    % Seek to start of file
    fileID = fopen(filename);
    
    % Read history dimensions & number of regions
    historyDimensions.numEpochs = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
    numRegions = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
    historyDimensions.numObjects = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
    historyDimensions.numOutputsPrObject = fread(fileID, historyDimensions.numObjects, SOURCE_PLATFORM_LONG_LONG_UINT);
   
    HEADER_BYTE_SIZE = 3*SOURCE_PLATFORM_USHORT_SIZE + historyDimensions.numObjects*SOURCE_PLATFORM_LONG_LONG_UINT_SIZE;
    
    % Compound stream sizes
    historyDimensions.epochSize = sum(historyDimensions.numOutputsPrObject);
    historyDimensions.streamSize = historyDimensions.epochSize * historyDimensions.numEpochs;
    
    % Preallocate struct array
    networkDimensions(numRegions).y_dimension = [];
    networkDimensions(numRegions).x_dimension = [];
    networkDimensions(numRegions).depth = [];
    networkDimensions(numRegions).isPresent = [];
    neuronOffsets = cell(numRegions,1); % {1} is left empty because V1 is not included
    
    % Read dimensions
    nrOfPresentLayers = 0;
    for r=1:numRegions,
        
        y_dimension = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        x_dimension = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        depth       = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        isPresent   = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        
        networkDimensions(r).y_dimension = y_dimension;
        networkDimensions(r).x_dimension = x_dimension;
        networkDimensions(r).depth = depth;
        networkDimensions(r).isPresent = isPresent;
        
        neuronOffsets{r}(y_dimension, x_dimension, depth).offset = [];
        neuronOffsets{r}(y_dimension, x_dimension, depth).nr = [];
        
        if isPresent,
            nrOfPresentLayers = nrOfPresentLayers + 1;
        end
    end
    
    % We compute the size of header just read
    NUM_FIELDS_PER_REGION = 4;
    
    headerSize = HEADER_BYTE_SIZE + numRegions*SOURCE_PLATFORM_USHORT_SIZE*NUM_FIELDS_PER_REGION;
    
    % Compute and store the offset of each neuron's datastream in the file, not V1
    offset = headerSize; 
    nrOfNeurons = 1;
    for r=2:numRegions,
        if networkDimensions(r).isPresent, % Continue if this region is included
            for d=1:networkDimensions(r).depth, % Region depth
                for row=1:networkDimensions(r).y_dimension, % Region row
                    for col=1:networkDimensions(r).x_dimension, % Region col

                        neuronOffsets{r}(row, col, d).offset = offset;
                        neuronOffsets{r}(row, col, d).nr = nrOfNeurons;

                        offset = offset + historyDimensions.streamSize * SOURCE_PLATFORM_FLOAT_SIZE;
                        nrOfNeurons = nrOfNeurons + 1;
                    end
                end
            end
        end
    end
    
    % Close file
    fclose(fileID);