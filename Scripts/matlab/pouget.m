%
%  pouget.m
%  SMI
%
%  Created by Bedeho Mender on 21/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function pouget()

    % A. Pouget & T. Sejnowski (1997)
    
    % Seed rng
    rng(33, 'twister');
    
    % Stimuli:
    % 441=21*21 pairs of retinal and eye positions.
    % 21 retinal locations in [-40,40]
    % 21 eye positions in [-20,20]
    retinalTargets = centerN(80, 21);
    eyeTargets = centerN(40, 21);
    numPatterns = length(retinalTargets)*length(eyeTargets);
    
    mexRetTarget = max(retinalTargets);
    maxEyeTarget = max(eyeTargets);
    
    % Input:
    % 121 units
    % \mu uniform in 12 increments \in [-60,60]
    % \sigma = 18
    % \inflection points uniform in 8 increments \in [-40,40]
    % slope = 8
    inputSigma = 18;
    sigmoidSlope = 8;
    retinalPreferences = centerDistance(60*2, 12);
    eyePreferences = centerDistance(40*2, 8);
    
    [eyeMesh retMesh] = meshgrid(retinalPreferences, eyePreferences);
    numInputNeurons = numel(retMesh);
    
    % Output:
    % 1 unit
    % \sigma = 18
    % \mu = 0
    outputSigma = 18;
    outputHeadPreferences = [-1 1];%-10:2:10;%[0]; -mexRetTarget:2:mexRetTarget;
    outputRetinalPreferences = [-1 1];%-10:2:10;%[0]; -mexRetTarget:2:mexRetTarget;
    numOutputNeurons = length(outputHeadPreferences) + length(outputRetinalPreferences);
    
    % Network Parameters
    learningrate = 0.001;
    numEpochs = 100;
    
    [inputPatterns, outputPatterns] = generatePatterns();
    numPatterns = length(inputPatterns);
    
    %% Train
    figure;
    
    synapses = rand(numOutputNeurons, numInputNeurons);
    error = zeros(1,numEpochs);
    
    for epochNr=1:numEpochs,
        
        for p=1:numPatterns,
            
            % get input and desired output
            input = inputPatterns(:,p);
            target = outputPatterns(:,p);
            
            % compute response
            response = synapses*input;
            
            % update synapses
            synapses = learningrate*(target - response)*input';
        end
        
        error(epochNr) = sum((target-response).^2);
    end
    
    plot(error);
    ylabel('Error');
    xlabel('Epoch');
    
    %% Synaptic weight distribution   
    figure;

    lineardata = synapses(:);
    max_deviation = max(lineardata);
    min_deviation = min(lineardata);
    ticks = min_deviation:(max_deviation-min_deviation)/100:max_deviation;
    
    hdist = hist(lineardata, ticks);

    hBar = bar(ticks,hdist','stacked','LineStyle','none');
    set(hBar(1),'FaceColor', [67,82,163]/255); %, {'EdgeColor'}, edgeColors

    xlim([min_deviation max_deviation]);
    
    hXLabel = xlabel('Synaptic Weight');
    hYLabel = ylabel('Number of Synapses');

    set([hYLabel hXLabel], 'FontSize', 16);
    set(gca, 'FontSize', 14);
    box off
    
    axis square
    
    
    %% Show Input->Hidden Weight matrix
    figure;
    imagesc(synapses);
    
    hXLabel = xlabel('Hidden Layer Unit');
    hYLabel = ylabel('Input Layer Unit');

    set([hYLabel hXLabel], 'FontSize', 16);
    set(gca, 'FontSize', 14);
    colorbar
    axis square
    
    %% Single unit weight plot
    
    figure;
    output_weight_vector = reshape(synapses(1,:), [length(retinalPreferences), length(eyePreferences)]);
    imagesc(output_weight_vector);
    
    %% DALE principle
    %{
    inputToHidden_numExcitatory = sum((synapses > 0)');
    inputToHidden_numInhibitory = sum((synapses < 0)');
    
    [receptivefieldPlot, yProjectionAxis, scatterAxis, xProjectionAxis, XLim, YLim] = scatterPlotWithMarginalHistograms({inputToHidden_numExcitatory}, {inputToHidden_numInhibitory}, 'XTitle', 'Excitatory Efferents', 'YTitle', 'Inhibitory Efferents', 'FaceColors', {[67,82,163]/255},'Location', 'SouthEast');
    %}
    
    % Generate stimuli
    function [inputPatterns, outputPatterns] = generatePatterns()

        inputPatterns = zeros(numInputNeurons, numPatterns);
        outputPatterns = zeros(numOutputNeurons, numPatterns);
        
        % Iterate all targets comboes
        counter = 1;
        for r=retinalTargets,
            for e=eyeTargets,
                
                % Input
                in = exp(-(r - retMesh).^2/(2*inputSigma^2)) .* 1./(1 + exp(sigmoidSlope * (eyeMesh - e)));
                
                inputPatterns(:,counter) = in(:);
                
                % Output
                h = r+e;
                
                if(mod(counter,13) == 110),
                    figure;
                    subplot(1,3,1);
                    imagesc(in);
                    subplot(1,3,2);
                    plot(exp(-((h - outputHeadPreferences).^2)/(2*outputSigma^2)));
                    title('head');
                    xlim([1 length(outputHeadPreferences)]);
                    ylim([0 1]);
                    subplot(1,3,3);
                    plot(exp(-((r - outputRetinalPreferences).^2)/(2*outputSigma^2)));
                    title('retinal');
                    xlim([1 length(outputRetinalPreferences)]);
                    ylim([0 1]);
                    x=1;
                end
                
                if(~isempty(outputHeadPreferences) && ~isempty(outputRetinalPreferences)),
                    outputPatterns(:,counter) = [exp(-((h - outputHeadPreferences).^2)/(2*outputSigma^2)) exp(-((r - outputRetinalPreferences).^2)/(2*outputSigma^2))];
                elseif(~isempty(outputHeadPreferences)),
                    outputPatterns(:,counter) = exp(-((h - outputHeadPreferences).^2)/(2*outputSigma^2));
                else
                    outputPatterns(:,counter) = exp(-((r - outputRetinalPreferences).^2)/(2*outputSigma^2));
                end

                counter = counter + 1;
            end
        end

    end

end