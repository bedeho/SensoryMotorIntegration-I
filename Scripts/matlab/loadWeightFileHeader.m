%
%  loadWeightFileHeader.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: 
%  * Load header of weight file
%  Input:
%  * filname
%  Output:
%  *networkDimensions: struct array (dimension,depth) of regions (incl. V1)
%  *historyDimensions: struct (numEpochs,numObjects,numTransforms,numOutputsPrTransform)
%

function [networkDimensions, neuronOffsets] = loadWeightFileHeader(filename)

    % Import global variables
    declareGlobalVars();
    
    global SOURCE_PLATFORM_USHORT;
    global SOURCE_PLATFORM_USHORT_SIZE;
    global SYNAPSE_ELEMENT_SIZE;
    
    % Open file
    fileID = fopen(filename);
    
    % Read number of regions
    numRegions = fread(fileID, 1, 'uint16');%SOURCE_PLATFORM_USHORT);

    % Preallocate struct array
    networkDimensions(numRegions).y_dimension = [];
    networkDimensions(numRegions).x_dimension = [];
    networkDimensions(numRegions).depth = [];
    
    % Allocate cell data structure, {1} is left empty because V1 is not
    % included
    neuronOffsets = cell(numRegions,1); 
    
    % Read dimensions and setup data structure & counter
    nrOfNeurons = 0;
    for r=1:numRegions,
        
        y_dimension = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        x_dimension = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        depth = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        
        networkDimensions(r).y_dimension = y_dimension;
        networkDimensions(r).x_dimension = x_dimension;
        networkDimensions(r).depth = depth;

        neuronOffsets{r}(y_dimension, x_dimension, depth).afferentSynapseCount = [];
        neuronOffsets{r}(y_dimension, x_dimension, depth).offset = [];
        
        if r > 1,
            nrOfNeurons = nrOfNeurons + y_dimension * x_dimension * depth;
        end
    end

    % Build list of afferentSynapse count for all neurons, and
    % cumulative sum over afferentSynapseLists up to each neuron (count),
    % this is for file seeking
    
    buffer = fread(fileID, nrOfNeurons, SOURCE_PLATFORM_USHORT);
    
    % We compute the size of header just read
    offset = SOURCE_PLATFORM_USHORT_SIZE*(1 + 3 * numRegions + nrOfNeurons);
    counter = 0;
    for r=2:numRegions,
        for d=1:networkDimensions(r).depth, % Region depth
            for row=1:networkDimensions(r).y_dimension, % Region row
                for col=1:networkDimensions(r).x_dimension, % Region col
                    
                    afferentSynapseCount = buffer(counter + 1);
                    
                    neuronOffsets{r}(row, col, d).afferentSynapseCount = afferentSynapseCount;
                    neuronOffsets{r}(row, col, d).offset = offset;
                    
                    offset = offset + afferentSynapseCount * SYNAPSE_ELEMENT_SIZE;
                    counter = counter + 1;
                end
            end
        end
    end
    
    if counter ~= nrOfNeurons,
        error('ERROR, unexpected number of neurons');
    end
    
    % Close file
    fclose(fileID);