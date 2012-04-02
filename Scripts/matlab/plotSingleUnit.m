%
%  plotSingleUnit.m
%  SMI (VisBack copy)
%
%  Created by Bedeho Mender on 16/01/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  Input=========
%  unit: [isPresent|firing|activation|inhibitedActivation|trace|stimulation|synapses(timestep, object, epoch, synapseNr)] 
%  Output========
%  Plots line plot of activity for spesific neuron

function plotSingleUnit(unit, historyDimensions, includeSynapses, maxEpoch)

    if nargin < 4,
        maxEpoch = historyDimensions.numEpochs; % pick all epochs
        
        if nargin < 3,
            includeSynapses = true;
        end
    end
    
    streamSize = maxEpoch * historyDimensions.epochSize;
    
    % Setup figure
    fig = figure();
    
    %% Plot neuron dynamics
    subplot(3,1,1);
    
    [traceLine, m1] = plotUnitData(unit.trace, 'g');
    [activationLine, m2] = plotUnitData(unit.activation, 'y');
    [firingLine, m3] = plotUnitData(unit.firingRate, 'b');
    [stimulationLine, m4] = plotUnitData(unit.stimulation, 'k');
    [effectiveTraceLine, m5] = plotUnitData(unit.effectiveTrace, '--m');
    
    legend('Trace','Activation','Firing','Stimulation','Effective Trace');
    
    addGrid();
    mFinal = 1.5*max([0.51 m1 m2 m3 m4]); % Used for axis
    axis([0 streamSize -0.01 mFinal]);
    
    %% Plot synapses
    
    if includeSynapses,
        
        synapses = unit.synapses;
        sizes = size(synapses);
        numberOfSynapses = sizes(end);
        
        %{
        % Iterate synapses
        m5 = 0;
        for s=1:numberOfSynapses,
            
            b = unit.synapses(:, :, 1:maxEpoch, s);
            v = reshape(b, [1 streamSize]);
            plot(v,'b');
            hold on;
            
            t = max(v);
            
            if t > m5,
                m5 = t,
            end
        end
        
        axis([0 streamSize -0.01 (m5*1.5)]);
        %}
        
        % Plot history of each synapse
        historyView = zeros(numberOfSynapses,streamSize);
        
        %% fix later, factor out axes slowness businuess
        potentiatedSynapses = subplot(3,1,2);
        maxSynapseValue = 0;
        for s=1:numberOfSynapses,

            v = synapses(:, :, 1:maxEpoch, s);
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
        for s=1:numberOfSynapses,

            v = historyView(s,:);
            
            if max(v) > v(1),
                plot(v);
                hold on;
            end
            
        end
        
        axis([0 streamSize -0.01 (maxSynapseValue*1.5)]);
        addGrid();
        
  
    end
    
    function [lineHandle, maxValue] = plotUnitData(unitData, color)
        
        % Get history array
        activity = reshape(unitData, [historyDimensions.numOutputsPrObject historyDimensions.numObjects maxEpoch]);

        % Plot
        v = activity(:, :, 1:maxEpoch);

        streamSize = maxEpoch * historyDimensions.epochSize;
        vect = reshape(v, [1 streamSize]);
        lineHandle = plot(vect, color);
        hold on;
        
        maxValue = max(vect);

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