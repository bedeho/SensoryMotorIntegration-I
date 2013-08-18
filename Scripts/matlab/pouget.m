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
    retinalPreferences = centerDistance(60*2, 12); %-mexRetTarget:2:mexRetTarget;
    eyePreferences = centerDistance(40*2, 8); %-maxEyeTarget:2:maxEyeTarget;
    
    [eyeMesh retMesh] = meshgrid(eyePreferences, retinalPreferences);
    numInputNeurons = numel(retMesh);
    
    % Output:
    % 1 unit
    % \sigma = 18
    % \mu = 0
    outputSigma = 18;
    outputHeadPreferences = -20:2:20%;-10:2:10; %-mexRetTarget:2:mexRetTarget; % -10:2:10;%
    outputRetinalPreferences = -20:2:20;%,[0]; -mexRetTarget:2:mexRetTarget; -10:2:10;
    numOutputNeurons = length(outputHeadPreferences) + length(outputRetinalPreferences);
    
    % Network Parameters
    learningrate = 0.05;
    numEpochs = 300;
    
    %% Train
    
    disp('Generating patterns');
    [inputPatterns, outputPatterns] = generatePatterns();
    
    synapses = rand(numOutputNeurons, numInputNeurons);
    totalAveragError = zeros(1,numEpochs);
    
    for epochNr=1:numEpochs,
        epochNr
        
        % do one round of learning
        counter = 1;
        for r=retinalTargets,
            for e=eyeTargets,
                
                % get input and desired output
                input = inputPatterns(:,:, counter);
                target = outputPatterns(:, counter);
                linear_input = input(:);

                % compute response
                response = synapses*linear_input;
                
                if((counter==100 && mod(epochNr,20) == 0) || nnz(isnan(response) > 0) > 0),
                    figure;

                    subplot(1,4,1);
                    imagesc(input);
                    title('input')

                    subplot(1,4,2);
                    plot(response,'r');
                    xlim([1 numOutputNeurons]);

                    subplot(1,4,3);
                    plot(target,'b');
                    xlim([1 numOutputNeurons]);
                    
                    subplot(1,4,4);
                    imagesc(reshape(synapses(10,:), [length(retinalPreferences), length(eyePreferences)]));
                    axis square
                    disp(['Retinal: ' num2str(r)]);
                    disp(['Eye: ' num2str(e)]);
                end

                % update synapses
                delta = learningrate*(target - response)*linear_input';
                
                synapses = synapses + delta;

                counter = counter + 1;
            end
        end

        % get error after last epoch
        error = 0;
        for r=retinalTargets,
            for e=eyeTargets,
                
                % get input and desired output
                [input target] = layers(r,e);
                linear_input = input(:);

                % compute response
                response = synapses*linear_input;
                
                % error
                error = error + sum((target-response).^2);
            end
        end
        
        totalAveragError(epochNr) = error/numOutputNeurons;
    end
    
    figure;
    semilogy(totalAveragError)
    hYLabel = ylabel('Average Error');
    hXLabel = xlabel('Epoch');
    disp(['Final error: ' num2str(totalAveragError(end))]);
    
    set([hYLabel hXLabel], 'FontSize', 16);
    set(gca, 'FontSize', 14);
    box off
    
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
    
    hXLabel = xlabel('Input Layer Unit');
    hYLabel = ylabel('Hidden Layer Unit');

    set([hYLabel hXLabel], 'FontSize', 16);
    set(gca, 'FontSize', 14);
    colorbar
    axis square
    
    %% Single unit weight plot
    
    %{
    figure;
    output_weight_vector = reshape(synapses(2,:), [length(retinalPreferences), length(eyePreferences)]);
    imagesc(output_weight_vector);
    title('head - weight vector');
    colorbar
    
    figure;
    imagesc(reshape(synapses(18,:), [length(retinalPreferences), length(eyePreferences)]));
    title('eye - weight vector');
    colorbar
    
    figure;
    for h=1: length(outputHeadPreferences),
        
        subplot(1, length(outputHeadPreferences),h);
        imagesc(reshape(synapses(h,:), [length(retinalPreferences), length(eyePreferences)]));
        title('head - weight vector');
    end
    
        figure;
    for h=1:length(outputRetinalPreferences),
        
        subplot(1, length(outputRetinalPreferences),h);
        imagesc(reshape(synapses(length(outputHeadPreferences)+ h,:), [length(retinalPreferences), length(eyePreferences)]));
        title('eye - weight vector');
    end
    %}    
    
    %% Dale principle
    
    
    inputToHidden_numExcitatory = sum((synapses >= 0)')
    inputToHidden_numInhibitory = sum((synapses < 0)')
    
    disp(['Num excitatory: ' num2str(sum(inputToHidden_numExcitatory))]);
    disp(['Num inhibitory: ' num2str(sum(inputToHidden_numInhibitory))]);
    
    [receptivefieldPlot, yProjectionAxis, scatterAxis, xProjectionAxis, XLim, YLim] = scatterPlotWithMarginalHistograms({inputToHidden_numExcitatory}, {inputToHidden_numInhibitory}, 'XTitle', 'Excitatory Efferents', 'YTitle', 'Inhibitory Efferents', 'FaceColors', {[67,82,163]/255},'Location', 'SouthEast');
    
    
    % Generate stimuli
    function [inputPatterns, outputPatterns] = generatePatterns()

        inputPatterns = zeros(length(retinalPreferences), length(eyePreferences), numPatterns);
        outputPatterns = zeros(numOutputNeurons, numPatterns);
        
        % Iterate all targets comboes
        counter = 1;
        
        for r_=retinalTargets,
            for e_=eyeTargets,
    
                [input, target] = layers(r_,e_);

                
                inputPatterns(:,:,counter) = input;
                outputPatterns(:,counter) = target;

                counter = counter + 1;
            end
        end

    end

    function [input target] = layers(r,e)
        
        input = exp(-(r - retMesh).^2/(2*inputSigma^2)) .* 1./(1 + exp(sigmoidSlope * (eyeMesh - e)));
        
        %input = exp(-(r - retMesh).^2/(2*inputSigma^2));
        target = [exp(-(((r+e) - outputHeadPreferences).^2)/(2*outputSigma^2)) exp(-((r - outputRetinalPreferences).^2)/(2*outputSigma^2))]';
        
    end

end