%
%  loadSynapseWeightHistoryHeader.m
%  SMI (VisBack copY)
%
%  Created by Bedeho Mender on 16/01/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  LOAD HEADER OF WEIGHT FILE
%  Input=========
%  fileID: Id of open file
%  Output========
%  networkDimensions: struct array (dimension,depth) of regions (incl. V1)
%  neuronOffsets: cell array of structs {region}{col,row,depth}.(afferentSynapseCount,offsetCount)
%  headerSize: bytes read, this is where the file pointer is left
function [networkDimensions, nrOfPresentLayers, historyDimensions, neuronOffsets] = loadSynapseWeightHistoryHeader(fileID)

    % Import global variables
    global SOURCE_PLATFORM_USHORT;
    global SOURCE_PLATFORM_USHORT_SIZE;
    global SOURCE_PLATFORM_FLOAT_SIZE;
    
    % Seek to start of file
    frewind(fileID);
    
    % Read history dimensions & number of regions
    v = fread(fileID, 4, SOURCE_PLATFORM_USHORT);
    
    historyDimensions.numEpochs = v(1);
    historyDimensions.numObjects = v(2);
    historyDimensions.numOutputsPrObject = v(3);
    numRegions = v(4);
    HEADER_START_SIZE = 4;
   
    % Compound stream sizes
    historyDimensions.objectSize = historyDimensions.numOutputsPrObject;
    historyDimensions.epochSize = historyDimensions.objectSize * historyDimensions.numObjects;
    historyDimensions.streamSize = historyDimensions.epochSize * historyDimensions.numEpochs;

    % Preallocate struct array
    numRegions = v(4);
    networkDimensions(numRegions).y_dimension = [];
    networkDimensions(numRegions).x_dimension = [];
    networkDimensions(numRegions).depth = [];
    networkDimensions(numRegions).isPresent = [];
    neuronOffsets = cell(numRegions,1); % {1} is left empty because V1 is not included
    
    % Read dimensions and setup data structure & counter
    nrOfNeurons = 0;
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
        
        if isPresent,
            
            neuronOffsets{r}(y_dimension, x_dimension, depth).offset = [];
            neuronOffsets{r}(y_dimension, x_dimension, depth).nr = [];
            
            nrOfPresentLayers = nrOfPresentLayers + 1;
            
            if r > 1 
                nrOfNeurons = nrOfNeurons + y_dimension * x_dimension * depth;
            end
        end
    end
    
    % Read in afferentSynapse count for all neurons
    buffer = fread(fileID, nrOfNeurons, SOURCE_PLATFORM_USHORT);
    
    % Compute the size of header just read
    NUM_FIELDS_PER_REGION = 4;
    headerSize = SOURCE_PLATFORM_USHORT_SIZE*(HEADER_START_SIZE + NUM_FIELDS_PER_REGION * numRegions + nrOfNeurons);
    
    % Maintain cumulative sum over afferentSynapseLists up to each neuron (count),
    % this is for file seeking
    offset = headerSize;
    counter = 0;
    for r=2:numRegions,
        if networkDimensions(r).isPresent, % Continue if this region is included
            for d=1:networkDimensions(r).depth, % Region depth
                for row=1:networkDimensions(r).y_dimension, % Region row
                    for col=1:networkDimensions(r).x_dimension, % Region col

                        afferentSynapseCount = buffer(counter + 1);
                        neuronOffsets{r}(row, col, d).afferentSynapseCount = afferentSynapseCount;
                        neuronOffsets{r}(row, col, d).offset = offset;

                        offset = offset + afferentSynapseCount * (4 * SOURCE_PLATFORM_USHORT_SIZE + SOURCE_PLATFORM_FLOAT_SIZE * historyDimensions.streamSize);
                        counter = counter + 1;
                    end
                end
            end
        end
    end
    
    % Check that we found the right number of neurons
    if counter ~= nrOfNeurons,
        error('ERROR, unexpected number of neurons');
    end