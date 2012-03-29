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

function plotSynapseHistory(folder, region, depth, row, col, includeSynapses, maxEpoch)

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
    
    % Setup figure
    fig = figure();
    title(['Row ' num2str(row) ' Col ' num2str(col) ' Region ' num2str(region)]);
    
    %% Plot neuron dynamics
    subplot(3,1,1);
    
    [traceLine, m1] = plotFile('trace.dat', 'g');
    [activationLine, m2] = plotFile('activation.dat', 'y');
    [firingLine, m3] = plotFile('firingRate.dat', 'r');
    [stimulationLine, m4] = plotFile('stimulation.dat', 'k');
    [effectiveTraceLine, m5] = plotFile('effectiveTrace.dat', '--m');
    
    legend('Firing','Trace','Activation','Stimulation','Effective Trace');
    
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
    
    %{
    function r = isMonotonicallyDecreasing(v)
        for i=1:(length(v)-1),
            if v(i) < v(i+1), % floating point sensitivty thing....
                r = 0;
                return;
            end
        end
        
        r = 1;
        return;
    end
    %}
    
    function [lineHandle, maxValue] = plotFile(filename, color)
        
        firingRateFile = [folder '/' filename];

        % Open file
        fileID = fopen(firingRateFile);

        % Read header
        [networkDimensions, nrOfPresentLayers, historyDimensions, neuronOffsets] = loadHistoryHeader(firingRateFile);

        % Get history array
        activity = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch);

        % Plot
        v = activity(:, :, 1:maxEpoch);

        streamSize = maxEpoch * historyDimensions.epochSize;
        vect = reshape(v, [1 streamSize]);
        lineHandle = plot(vect, color);
        hold on;
        
        maxValue = max(vect);

        fclose(fileID);
    end

    function addGrid() 

        % No longer valid, transforms dont exist!
        % Draw vertical divider for each transform
        %if historyDimensions.numOutputsPrTransform > 1,
        %    x = historyDimensions.numOutputsPrTransform : historyDimensions.numOutputsPrTransform : streamSize;
        %    gridxy(x, 'Color', 'c', 'Linestyle', ':');
        %end

        hold on

        % Draw vertical divider for each object
        if historyDimensions.numObjects > 1,
            x = historyDimensions.objectSize : historyDimensions.objectSize : streamSize;
            gridxy(x, 'Color', 'b', 'Linestyle', '--');
        end

        hold on

        % Draw vertical divider for each epoch
        if maxEpoch > 1,
            x = historyDimensions.epochSize : historyDimensions.epochSize : streamSize;
            gridxy(x, 'Color', 'k', 'Linestyle', '-');
        end

        hold on
    end
end