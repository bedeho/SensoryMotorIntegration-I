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

function trainingDynamics(unit, historyDimensions, networkDimensions, includeSynapses, stimuliName)


    % Import global variables
    %declareGlobalVars();
    
    eyePositionDimensionInputPopulationSize = floor(networkDimensions(1).x_dimension/2);
    retinalLocationDimensionInputPopulationSize = floor(networkDimensions(1).y_dimension/2);
    
    %UGLY!!!
    stimuliName = strrep(stimuliName,'stdTest','training');

    % Output frequency
    timestep = 0.01
    outputAtTimeStepMultiple = 2
    tickSize = timestep*outputAtTimeStepMultiple;
    
    %% Load buffers
    
    % Neuronal variables
    ticksInBuffer = 20;
    plotBuffer = zeros(3,ticksInBuffer)
    
    traceBuffer = unit.trace; %getActivity('trace.dat');
    activationBuffer = unit.activation; %getActivity('activation.dat');
    firingBuffer = unit.firingRate; %getActivity('firingRate.dat');
    stimulationBuffer = unit.stimulation; %getActivity('stimulation.dat');
    presynapticSynapseSource = unit.presynapticSynapseSource;
    
    %effectiveTraceBuffer = getActivity('effectiveTrace.dat');
    inhibitedActivationBuffer = unit.inhibitedActivation; %getActivity('inhibitedActivation.dat');
    
    % Synapses
    if includeSynapses,
        
        synapses = unit.synapses;
        
        [streamSize numSynapses] = size(unit.synapses)
        
        % What to show
        sourceRegion = [1];
        sourceDepth = [1]; % planar = 2;
        numRegions = length(sourceRegion);
        
        for r=1:numRegions,
            
            regionNr = sourceRegion(r);
            depthNr = sourceDepth(r);
            numRows = networkDimensions(regionNr).y_dimension;
            numCols = networkDimensions(regionNr).x_dimension;
            
            matrixes{regionNr,depthNr} = zeros(numRows,numCols);
            
        end
    
    end
    
    % Load stimuli data
    [samplingRate, numberOfSimultanousTargets, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Stimuli_Load(stimuliName);
    totalStimuliDuration = length(buffer)*(1/samplingRate);
    
    % Start figure and setup mouse click callback
    h = figure();
    set(h, 'ButtonDownFcn', {@clickCallback}); % Setup callback
    running = false;
    
    % Setup and start timer
    % Good video on timers: http://blogs.mathworks.com/pick/2008/05/05/advanced-matlab-timer-objects/
    t = 1;
    timerObject = timer('Period', 0.08, 'ExecutionMode', 'fixedSpacing');
    set(timerObject, 'TimerFcn', {@trainingDynamics_Draw});
    
    goSlow = false;

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
        ia = inhibitedActivationBuffer(t);
        

        plotBuffer(:,end) = [tr; f; s]; % [tr; a; f; s; ia];
        
        maxVal = max(1.1,1.1*max(max(plotBuffer))); % 1.1
        maxVal = 1.1;
        minVal = min(-0.1,min(min(plotBuffer)));
        minVal = -0.1;
        
        % Plot buffer
        subplot(numRegions+1, 1,1);%% subplot(numRegions+1+1, 1,1)
        plot(plotBuffer');
        axis([1 ticksInBuffer minVal maxVal]); 
        title(['tick = ' num2str(t) '/' num2str(streamSize)]);
        %legend('Trace','Activation','Firing','Stimulation','Inhibition'); % 
        legend('Trace','Firing','Stimulation'); % 
        
        % GET stimulus locations - IT IS FUDGEDD, not 100.00% correct
        simulationTime = (t-1)*tickSize;
        timeIntoEpoch = mod(simulationTime, totalStimuliDuration);
        lineCounter = floor(timeIntoEpoch/(1/samplingRate))+1;
        if lineCounter > length(buffer)
            lineCounter = length(buffer)-1;
            disp('is done');
        end
        
        eyePosition = buffer(lineCounter, 1);
        retinalPositions = buffer(lineCounter, 2:(numberOfSimultanousTargets + 1));
        
        eyePosition_MatrixCord = eyePosition+eyePositionDimensionInputPopulationSize;
        retinalPositions_MatrixCord = retinalLocationDimensionInputPopulationSize-retinalPositions;
        
        
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

                subplot(numRegions+1,1,r+1); %% subplot(numRegions+1+1, 1,1)

                regionNr = sourceRegion(r);
                depthNr = sourceDepth(r);

                imagesc(matrixes{regionNr,depthNr});
                colorbar
                pbaspect([networkDimensions(regionNr).x_dimension networkDimensions(regionNr).y_dimension 1]);
                %colobar
                
                hold on
                plot(eyePosition_MatrixCord*ones(numberOfSimultanousTargets), retinalPositions_MatrixCord , 'xw', 'MarkerSize',10,'LineWidth',10);

            end

        end
        

        
        %{
        if ~isnan(eyePosition),
            
            subplot(numRegions+1+1, 1, numRegions+1+1);
            plot(eyePosition*ones(numberOfSimultanousTargets), retinalPositions , 'o');
            pbaspect([eyePositionFieldSize visualFieldSize 1]);
            axis([-eyePositionFieldSize/2 eyePositionFieldSize/2 -visualFieldSize/2 visualFieldSize/2]);
        else
            disp('isnan!!!');
        end
        %}

        % Update where we are
        if goSlow || tr > 0.2 || f > 0.2,
            dt = 2;
        else
            dt = 50;
        end
        
        t = t + dt;
        
    end

    function clickCallback(varargin)
        
        clickType = get(gcf,'SelectionType');
        
        % Left click
        if strcmp(clickType,'normal'),
            
            if running,
                stop(timerObject);
            else
                start(timerObject);
            end

            running = ~running;
        else
            
            %Right click
            goSlow = ~goSlow
        end
    end
end