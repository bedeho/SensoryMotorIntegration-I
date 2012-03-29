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
    subplot(2,1,1);
    
    [traceLine, m1] = plotUnitData(unit.trace, 'g');
    [activationLine, m2] = plotUnitData(unit.activation, 'y');
    [firingLine, m3] = plotUnitData(unit.firingRate, 'r');
    [stimulationLine, m4] = plotUnitData(unit.stimulation, 'k');
    [effectiveTraceLine, m5] = plotUnitData(unit.effectiveTrace, '--m');
    
    legend('Trace','Activation','Firing','Stimulation','Effective Trace');
    
    addGrid();
    mFinal = 1.5*max([0.51 m1 m2 m3 m4]); % Used for axis
    axis([0 streamSize -0.01 mFinal]);
    
    %% Plot synapses
    subplot(2,1,2);
    
    if includeSynapses,
        
        synapses = unit.synapses;
        sizes = size(synapses);
        numberOfSynapses = sizes(end);
        
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