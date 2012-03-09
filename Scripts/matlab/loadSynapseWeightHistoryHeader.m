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
function [networkDimensions, historyDimensions, neuronOffsets] = loadSynapseWeightHistoryHeader(fileID)

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
   
    % Compound stream sizes
    historyDimensions.objectSize = historyDimensions.numOutputsPrObject;
    historyDimensions.epochSize = historyDimensions.objectSize * historyDimensions.numObjects;
    historyDimensions.streamSize = historyDimensions.epochSize * historyDimensions.numEpochs;

    % Preallocate struct array
    numRegions = v(4);
    networkDimensions(numRegions).y_dimension = [];
    networkDimensions(numRegions).x_dimension = [];
    networkDimensions(numRegions).depth = []; 
    neuronOffsets = cell(numRegions,1); % {1} is left empty because V1 is not included
    
    % Read dimensions and setup data structure & counter
    nrOfNeurons = 0;
    for r=1:numRegions,
        
        y_dimension = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        x_dimension = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        depth       = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        
        networkDimensions(r).y_dimension = y_dimension;
        networkDimensions(r).x_dimension = x_dimension;
        networkDimensions(r).depth = depth;
        
        neuronOffsets{r}(y_dimension, x_dimension, depth).offset = [];
        neuronOffsets{r}(y_dimension, x_dimension, depth).nr = [];
        
        if r > 1,
            nrOfNeurons = nrOfNeurons + y_dimension * x_dimension * depth;
        end
        
    end
    
    % Compute the size of header just read
    headerSize = SOURCE_PLATFORM_USHORT_SIZE*(4 + 3 * numRegions + nrOfNeurons);
    
    % Read in afferentSynapse count for all neurons
    buffer = fread(fileID, nrOfNeurons, SOURCE_PLATFORM_USHORT);
    
    % Maintain cumulative sum over afferentSynapseLists up to each neuron (count),
    % this is for file seeking
    offset = headerSize;
    counter = 0;
    for r=2:numRegions,
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
    
    if counter ~= nrOfNeurons,
        error('ERROR, unexpected number of neurons');
    end
    
    % We compute the size of header just read
    % headerSize = SOURCE_PLATFORM_USHORT_SIZE*(1 + 2 * numRegions + nrOfNeurons);