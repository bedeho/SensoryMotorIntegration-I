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
    inputSigma = 3;
    sigmoidSlope = 18;
    retinalPreferences = centerDistance(60*2, 10);
    eyePreferences = centerDistance(40*2, 4);
    
    [eyeMesh retMesh] = meshgrid(retinalPreferences, eyePreferences);
    numInputNeurons = numel(retMesh);
    
    % Output:
    % 1 unit
    % \sigma = 18
    % \mu = 0
    outputSigma = 18;
    outputHeadPreferences = -10:2:10;%, [0]; -mexRetTarget:2:mexRetTarget;
    outputRetinalPreferences =-10:2:10;%,[0]; -mexRetTarget:2:mexRetTarget;
    numOutputNeurons = length(outputHeadPreferences) + length(outputRetinalPreferences);
    
    % Network Parameters
    learningrate = 0.1;
    numEpochs = 400;
    
    %[inputPatterns, outputPatterns] = generatePatterns();
    %numPatterns = length(inputPatterns);
    
    %% Train
    figure;
    
    synapses = rand(numOutputNeurons, numInputNeurons);
    totalAveragError = zeros(1,numEpochs);
    
    for epochNr=1:numEpochs,
        epochNr
        
        % do one round of learning
        counter = 0;
        for r=retinalTargets,
            for e=eyeTargets,
                
                % get input and desired output
                [input, target] = layers(r,e);
                linear_input = input(:);

                % compute response
                response = synapses*linear_input;
                
                %{
                if(counter==0 && mod(epochNr,20) == 0),
                    figure;

                    subplot(1,3,1);
                    imagesc(input);
                    title('input')

                    subplot(1,3,2);
                    plot(response,'r');
                    xlim([1 numOutputNeurons]);

                    subplot(1,3,3);
                    plot(target,'b');
                    xlim([1 numOutputNeurons]);

                    x=1;
                end
                  %}  
                
                % update synapses
                synapses = synapses + learningrate*(target - response)*linear_input';

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
    
    plot(totalAveragError)
    ylabel('Error');
    xlabel('Epoch');
    
    totalAveragError
    
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
    output_weight_vector = reshape(synapses(2,:), [length(retinalPreferences), length(eyePreferences)]);
    imagesc(output_weight_vector);
    
    %% DALE principle
    
    inputToHidden_numExcitatory = sum((synapses > 0)');
    inputToHidden_numInhibitory = sum((synapses < 0)');
    
    [receptivefieldPlot, yProjectionAxis, scatterAxis, xProjectionAxis, XLim, YLim] = scatterPlotWithMarginalHistograms({inputToHidden_numExcitatory}, {inputToHidden_numInhibitory}, 'XTitle', 'Excitatory Efferents', 'YTitle', 'Inhibitory Efferents', 'FaceColors', {[67,82,163]/255},'Location', 'SouthEast');
    
    function [input target] = layers(r,e)
        
        input = exp(-(r - retMesh).^2/(2*inputSigma^2)) .* 1./(1 + exp(sigmoidSlope * (eyeMesh - e)));
        target = [exp(-(((r+e) - outputHeadPreferences).^2)/(2*outputSigma^2)) exp(-(((r+e) - outputRetinalPreferences).^2)/(2*outputSigma^2))]';
        
    end

end