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

function [singleUnits, historyDimensions, nrOfPresentLayers] = loadSingleUnitRecordings(filename) % maxEpoch

    % Import global variables
    global SOURCE_PLATFORM_USHORT;
    global SOURCE_PLATFORM_FLOAT;
    global SOURCE_PLATFORM_LONG_LONG_UINT;
    global SOURCE_PLATFORM_LONG_LONG_UINT_SIZE;
    
    % Seek to start of file
    fileID = fopen(filename);
    
    %{
    % Read history dimensions & number of regions
    v = fread(fileID, 4, SOURCE_PLATFORM_USHORT);
    
    historyDimensions.numEpochs = v(1);
    historyDimensions.numObjects = v(2);
    historyDimensions.numOutputsPrObject = v(3);
    numRegions = v(4);
    
    % Compound stream sizes
    historyDimensions.objectSize = historyDimensions.numOutputsPrObject;
    historyDimensions.epochSize = historyDimensions.objectSize * historyDimensions.numObjects;
    historyDimensions.streamSize = historyDimensions.epochSize * historyDimensions.numEpochs
    %}
    
    historyDimensions.numEpochs = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
    numRegions = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
    historyDimensions.numObjects = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
    historyDimensions.numOutputsPrObject = fread(fileID, historyDimensions.numObjects, SOURCE_PLATFORM_LONG_LONG_UINT);
    
    numOutputsPrObject = historyDimensions.numOutputsPrObject;
    
    %if(any(numOutputsPrObject(1)*ones(1,historyDimensions.numObjects) ~= numOutputsPrObject')),
    %    error('All objects must have same number of outputs.');
    %end
   
    historyDimensions.epochSize = sum(historyDimensions.numOutputsPrObject);
    historyDimensions.streamSize = historyDimensions.epochSize * historyDimensions.numEpochs;
    
    
    % Preallocate struct array
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
        singleUnits{r}(y_dimension, x_dimension, depth).effectiveTrace = [];
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
    %dimensionStructure = [historyDimensions.numOutputsPrObject historyDimensions.numObjects maxEpoch];
    
    % recode: {object, epoch}->timestep
    %{
    
    
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
    %}
    
    
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
        singleUnits{regionNr}(row, col, depth).firingRate           = firingRate; %reshape(firingRate, dimensionStructure); % firingRate
        
        activation = fread(fileID, historyDimensions.streamSize, SOURCE_PLATFORM_FLOAT);
        singleUnits{regionNr}(row, col, depth).activation           = activation; %reshape(activation, dimensionStructure); % activation
        
        inhibitedActivation = fread(fileID, historyDimensions.streamSize, SOURCE_PLATFORM_FLOAT);
        singleUnits{regionNr}(row, col, depth).inhibitedActivation  = inhibitedActivation; %reshape(inhibitedActivation, dimensionStructure); % inhibitedActivation
        
        trace = fread(fileID, historyDimensions.streamSize, SOURCE_PLATFORM_FLOAT);
        singleUnits{regionNr}(row, col, depth).trace                = trace; %reshape(trace, dimensionStructure); % trace
        
        stimulation = fread(fileID, historyDimensions.streamSize, SOURCE_PLATFORM_FLOAT);
        singleUnits{regionNr}(row, col, depth).stimulation          = stimulation; %reshape(stimulation, dimensionStructure); % stimulation

        effectiveTrace = fread(fileID, historyDimensions.streamSize, SOURCE_PLATFORM_FLOAT);
        singleUnits{regionNr}(row, col, depth).effectiveTrace          = effectiveTrace; %reshape(effectiveTrace, dimensionStructure); % stimulation        
        
        % Synapse history - history of all in one read
        % file << afferentSynapses[s].weightHistory[t];
        weightHistory = fread(fileID, fanIn * historyDimensions.streamSize, SOURCE_PLATFORM_FLOAT);
        
        % Structure into array
        singleUnits{regionNr}(row, col, depth).synapses = reshape(weightHistory, [historyDimensions.streamSize fanIn]); %reshape(weightHistory, [dimensionStructure fanIn]); % (timestep, transform, object, epoch, synapseNr)
        
    end
    
    % Close file
    fclose(fileID);