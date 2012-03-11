%
%  loadSingleUnitRecordings.m
%  SMI
%
%  Created by Bedeho Mender on 09/03/12.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: 
%  Input:
%  * filname
%  Output:
%  * singleUnits: {regionNr}(row,col,depth).[isPresent|firing|activation|inhibitedActivation|trace|stimulation|synapses(timestep, object, epoch, synapseNr)]

function [singleUnits, historyDimensions, nrOfPresentLayers] = loadSingleUnitRecordings(filename, maxEpoch)

    % Import global variables
    global SOURCE_PLATFORM_USHORT;
    global SOURCE_PLATFORM_FLOAT;
    
    % Seek to start of file
    fileID = fopen(filename);
    
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
    networkDimensions(numRegions).isPresent = [];
    
    singleUnits = cell(numRegions,1); % {1} is left empty because V1 is not included
    
    % Read dimensions and setup data structure & counter
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
        
        % We assume all individual cells to be abscent for now
        singleUnits{r}(y_dimension, x_dimension, depth).isPresent = 0;
        for row=1:y_dimension,
            for col=1:x_dimension,
                singleUnits{r}(row, col, 1).isPresent = 0;
            end
        end
        
        singleUnits{r}(y_dimension, x_dimension, depth).firingRate = [];
        singleUnits{r}(y_dimension, x_dimension, depth).activation = [];
        singleUnits{r}(y_dimension, x_dimension, depth).inhibitedActivation = [];
        singleUnits{r}(y_dimension, x_dimension, depth).trace = [];
        singleUnits{r}(y_dimension, x_dimension, depth).stimulationHistory = [];
        singleUnits{r}(y_dimension, x_dimension, depth).synapses = [];
        
        if isPresent,         
            nrOfPresentLayers = nrOfPresentLayers + 1;
        end
    end
    
    % Start reading neuron histories
    if nargin < 2,
        maxEpoch = historyDimensions.numEpochs;
    end
    
    % HistoryDimensions
    dimensionStructure = [historyDimensions.numOutputsPrObject historyDimensions.numObjects maxEpoch];
    
    % Read each one cell at a time
    while 1
        
        % Neuron description:
        % file << n->region->regionNr << n->depth << n->row << n->col << static_cast<u_short>(afferentSynapses.size())
        % ushort,ushort,ushort,ushort,ushort
        
        v = fread(fileID, 5, SOURCE_PLATFORM_USHORT);
        
        % Check that we reached end of file,
        % feof() does not cut it.
        if isempty(v),
            break;
        end
        
        regionNr = v(1)+1;
        depth = v(2)+1;
        row = v(3)+1;
        col = v(4)+1;
        fanIn = v(5);
        
        % Mark as present
        singleUnits{regionNr}(row, col, depth).isPresent = 1;
        
        % Read streams containing: firingrate, activation, inhibitedActivation, trace and stimulation
        % For syntactic simplicity we just do one by one,
        firingRate = fread(fileID, historyDimensions.streamSize, SOURCE_PLATFORM_FLOAT);
        singleUnits{regionNr}(row, col, depth).firingRate           = reshape(firingRate, dimensionStructure); % firingRate
        
        activation = fread(fileID, historyDimensions.streamSize, SOURCE_PLATFORM_FLOAT);
        singleUnits{regionNr}(row, col, depth).activation           = reshape(activation, dimensionStructure); % activation
        
        inhibitedActivation = fread(fileID, historyDimensions.streamSize, SOURCE_PLATFORM_FLOAT);
        singleUnits{regionNr}(row, col, depth).inhibitedActivation  = reshape(inhibitedActivation, dimensionStructure); % inhibitedActivation
        
        trace = fread(fileID, historyDimensions.streamSize, SOURCE_PLATFORM_FLOAT);
        singleUnits{regionNr}(row, col, depth).trace                = reshape(trace, dimensionStructure); % trace
        
        stimulation = fread(fileID, historyDimensions.streamSize, SOURCE_PLATFORM_FLOAT);
        singleUnits{regionNr}(row, col, depth).stimulation          = reshape(stimulation, dimensionStructure); % stimulation
        
        % Synapse history - history of all in one read
        % file << afferentSynapses[s].weightHistory[t];
        weightHistory = fread(fileID, fanIn * historyDimensions.streamSize, SOURCE_PLATFORM_FLOAT);
        
        % Structure into array
        singleUnits{regionNr}(row, col, depth).synapses = reshape(weightHistory, [dimensionStructure fanIn]); % (timestep, transform, object, epoch, synapseNr)
        
    end
    
    % Close file
    fclose(fileID);
    
    %{
    % Compute the size of header just read
    NUM_FIELDS_PER_REGION = 4;
    headerSize = SOURCE_PLATFORM_USHORT_SIZE*(4 + NUM_FIELDS_PER_REGION * numRegions + nrOfNeurons);
    
    % Read in afferentSynapse count for all neurons
    buffer = fread(fileID, nrOfNeurons, SOURCE_PLATFORM_USHORT);
    
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
    %}