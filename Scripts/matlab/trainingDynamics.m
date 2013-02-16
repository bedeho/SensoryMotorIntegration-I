%
%  plotSynapseHistory.m
%  SMI (VisBack copy)
%
%  Created by Bedeho Mender on 16/01/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  Input=========
%  filename: filename of weight file
%  region: region to plot, V1 = 1
%  depth: region depth to plot
%  row: neuron row
%  col: neuron column
%  maxEpoch: last epoch to plot
%  Output========
%  Plots line plot of activity for spesific neuron

function trainingDynamics(folder, region, depth, row, col, includeSynapses, maxEpoch)

    % Import global variables
    declareGlobalVars();
    
    % Get history dimensions
    [networkDimensions, nrOfPresentLayers, historyDimensions] = getHistoryDimensions([folder '/firingRate.dat']);
    
    if nargin < 7,
        maxEpoch = historyDimensions.numEpochs; % pick all epochs
        
        if nargin < 6,
            includeSynapses = true;
        end
    end
    
    streamSize = maxEpoch * historyDimensions.epochSize;
    
    %% Load buffers
    
    % Neuronal variables
    ticksInBuffer = 20;
    plotBuffer = zeros(4,ticksInBuffer);
    
    traceBuffer = getActivity('trace.dat');
    activationBuffer = getActivity('activation.dat');
    firingBuffer = getActivity('firingRate.dat');
    stimulationBuffer = getActivity('stimulation.dat');
    %effectiveTraceBuffer = getActivity('effectiveTrace.dat');
    %InhibitedActivationBuffer = getActivity('inhibitedActivation.dat');
    
    % Synapses
    if includeSynapses,
        
        synapseFile = [folder '/synapticWeights.dat'];

        % Open file
        fileID = fopen(synapseFile);

        % Read header
        [networkDimensions, nrOfPresentLayers, historyDimensions, neuronOffsets] = loadSynapseWeightHistoryHeader(fileID);

        % Get history array
        synapses = synapseHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch);
        
        % Close file
        fclose(fileID);
        
        % What to show
        sourceRegion = [1];
        sourceDepth = [1];
        numRegions = length(sourceRegion);
        
        for r=1:numRegions,
            
            regionNr = sourceRegion(r);
            depthNr = sourceDepth(r);
            numRows = networkDimensions(regionNr).y_dimension;
            numCols = networkDimensions(regionNr).x_dimension;
            
            matrixes{regionNr,depthNr} = zeros(numRows,numCols);
            
        end
    
    end
    
    %% Go through time
    
    % Setup figure
    figure();

    % Iterate
    for epoch=1:maxEpoch,
        for object=1:historyDimensions.numObjects,
            for tick=1:historyDimensions.numOutputsPrObject,
                
                title({['Epoch: ' num2str(epoch)], ['Object: ' num2str(object)], ['Tick: ' num2str(tick)]}); % ddd
                
                % Plot neuronal values
                subplot(numRegions, 1,1);
                
                % Update buffer
                plotBuffer = plotBuffer(:,1:(end-1)); % shift back
                t = traceBuffer(tick, object, epoch);
                a = activationBuffer(tick, object, epoch);
                f = firingBuffer(tick, object, epoch);
                s = stimulationBuffer(tick, object, epoch);
                
                plotBuffer(:,end) = [t; a; f; s];
                
                % Plot buffer
                plot(plotBuffer);
                
                % Add Legend
                %legend('Trace','Activation','Firing','Stimulation','Inhibition');
                
                %% Plot synapses
                if includeSynapses,
                    
                    % clear out matrixes
                    for r=1:numRegions,
                        matrixes{r} = zeros(size(matrixes{r}));
                    end
                    
                    % Iterate synapses and populate matrixes
                    for s=1:length(synapses),
                        
                        %synapses(s).region/depth/row/col/activity [historyDimensions.numOutputsPrObject historyDimensions.numObjects maxEpoch]
                        
                        regionNr = synapses(s).region;
                        depthNr = synapses(s).depth;
                        row_ =  synapses(s).row;
                        col_ = synapses(s).col;
                        
                        matrixes{regionNr,depthNr}(row_,col_) = synapses(s).activity(tick,object,epoch);
                    end
                    
                    % Show matrices
                    for r=1:numRegions,
                        
                        subplot(numRegions,r,1);
                        
                        regionNr = sourceRegion(r);
                        depthNr = sourceDepth(r);

                        imagesc(matrixes{regionNr,depthNr});
            
                    end

                end
            end
        end
    end
 
    function activity = getActivity(filename)
        
        firingRateFile = [folder '/' filename];

        % Open file
        fileID = fopen(firingRateFile);

        % Read header
        [networkDimensions, nrOfPresentLayers, historyDimensions, neuronOffsets] = loadHistoryHeader(firingRateFile);

        % Get history array
        activity = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch);

        % Close file
        fclose(fileID);
    end
    
    %{
    
    
    
    
    
    
    %% Plot neuron dynamics
    subplot(3,1,1);
    

    
    mFinal = 1.5*max([0.51 m1 m2 m3 m4 m5]); % Used for axis
    axis([0 streamSize -0.01 mFinal]);
    addGrid();
    
    %% Plot synapses
    if includeSynapses,
        
        synapseFile = [folder '/synapticWeights.dat'];

        % Open file
        fileID = fopen(synapseFile);

        % Read header
        [networkDimensions, nrOfPresentLayers, historyDimensions, neuronOffsets] = loadSynapseWeightHistoryHeader(fileID);

        % Get history array
        synapses = synapseHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch);
        fclose(fileID);
        
        % Plot history of each synapse
        historyView = zeros(length(synapses),streamSize);
        
        %% fix later, factor out axes slowness businuess
        potentiatedSynapses = subplot(3,1,2);
        maxSynapseValue = 0;
        for s=1:length(synapses),

            v = synapses(s).activity(:, :, 1:maxEpoch);
            vect = reshape(v, [1 streamSize]);
            historyView(s,:) = vect;
            
            hold on;
            plot(vect);
            
            tmpMax = max(vect);
            
            if tmpMax > maxSynapseValue,
                maxSynapseValue = tmpMax;
            end
            
        end

        axis([0 streamSize -0.01 (maxSynapseValue*1.5)]);
        addGrid();
        
        %imagesc(historyView);
        %colormap gray
        %axis tight
        
        %% Traditional view
        allSynapses = subplot(3,1,3);
        for s=1:length(synapses),

            v = historyView(s,:);
            
            if max(v) > v(1),
                plot(v);
                hold on;
            end
            
        end
        
        axis([0 streamSize -0.01 (maxSynapseValue*1.5)]);
        addGrid();
        
    end
    %}

end