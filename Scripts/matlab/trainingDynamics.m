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

function trainingDynamics(unit, historyDimensions, networkDimensions, includeSynapses, maxEpoch)


    % Import global variables
    declareGlobalVars();
    
    if nargin < 7,
        maxEpoch = historyDimensions.numEpochs; % pick all epochs
        
        if nargin < 6,
            includeSynapses = true;
        end
    end
    
    %% Load buffers
    
    % Neuronal variables
    ticksInBuffer = 20;
    plotBuffer = zeros(4,ticksInBuffer);
    
    traceBuffer = unit.trace; %getActivity('trace.dat');
    activationBuffer = unit.activation; %getActivity('activation.dat');
    firingBuffer = unit.firingRate; %getActivity('firingRate.dat');
    stimulationBuffer = unit.stimulation; %getActivity('stimulation.dat');
    presynapticSynapseSource = unit.presynapticSynapseSource;
    
    %effectiveTraceBuffer = getActivity('effectiveTrace.dat');
    %InhibitedActivationBuffer = getActivity('inhibitedActivation.dat');
    
    % Synapses
    if includeSynapses,
        
        synapses = unit.synapses;
        
        [streamSize numSynapses] = size(unit.synapses)
        
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
    
    % Start figure and setup mouse click callback
    h = figure();
    set(h, 'ButtonDownFcn', {@clickCallback}); % Setup callback
    running = false;
    
    % Setup and start timer
    % Good video on timers: http://blogs.mathworks.com/pick/2008/05/05/advanced-matlab-timer-objects/
    t = 1;
    timerObject = timer('Period', 0.5, 'ExecutionMode', 'fixedSpacing');
    set(timerObject, 'TimerFcn', {@trainingDynamics_Draw});
    
    
    %{
    global t, streamSize, timerObject, plotBuffer, traceBuffer,
    ticksInBuffer, matrixes, includeSynapses, stimulationBuffer, numRegions,
    activationBuffer, firingBuffer, synapses;
    %}
    
    function trainingDynamics_Draw(obj, event)
        
        if t > streamSize,
            disp('End of data');
            stop(timerObject);
            delete(timerObject);
            return;
        end

        % Update neuronal buffer
        plotBuffer(:,1:(end-1)) = plotBuffer(:,2:end); % shift back
        tr = traceBuffer(t);
        a = activationBuffer(t);
        f = firingBuffer(t);
        s = stimulationBuffer(t);

        plotBuffer(:,end) = [tr; a; f; s];

        % Plot buffer
        subplot(numRegions+1, 1,1);
        plot(plotBuffer');
        axis([1 ticksInBuffer -0.1 1.1]); 
        title(['tick = ' num2str(t) '/' num2str(streamSize)]);
        legend('Trace','Activation','Firing','Stimulation'); % ,'Inhibition'
        
        % Plot synapses
        if includeSynapses,

            % clear out matrixes
            for r=1:numRegions,
                matrixes{r} = zeros(size(matrixes{r}));
            end

            % Iterate synapses and populate matrixes
            for s=1:numSynapses,

                %synapses(s).region/depth/row/col/activity [historyDimensions.numOutputsPrObject historyDimensions.numObjects maxEpoch]

                regionNr = presynapticSynapseSource(1,s);
                depthNr = presynapticSynapseSource(2,s);
                row_ =  presynapticSynapseSource(3,s);
                col_ = presynapticSynapseSource(4,s);

                matrixes{regionNr,depthNr}(row_,col_) = synapses(t,s);
            end

            % Show matrices
            for r=1:numRegions,

                subplot(numRegions+1,1,r+1);

                regionNr = sourceRegion(r);
                depthNr = sourceDepth(r);

                imagesc(matrixes{regionNr,depthNr});
                colobar

            end

        end
        
        t = t + 2;
        
    end

    function clickCallback(varargin)
        
        if running,
            stop(timerObject);
        else
            start(timerObject);
        end
        
        running = ~running;
    end
end