%
%  zipser.m
%  SMI
%
%  Created by Bedeho Mender on 21/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function zipser()

    % D. Zipser & R. Andersen (1988)
    
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
    
    [retMesh,eyeMesh] = meshgrid(retinalPreferences, eyePreferences);
    numInputNeurons = length(retMesh)*length(eyeMesh);
    
    % Output:
    % 1 unit
    % \sigma = 18
    % \mu = 0
    outputSigma = 18;
    outputHeadPreferences = [0];
    numOutputNeurons = length(outputHeadPreferences);
    
    % Stimuli:
    % 441=21*21 pairs of retinal and eye positions.
    % 21 retinal locations in [-40,40]
    % 21 eye positions in [-20,20]
    retinalTargets = centerN(80, 21);
    eyeTargets = centerN(40, 21);
    numPatterns = length(retinalTargets)*length(eyeTargets); %[retTargetMesh,eyeTargetMesh] = meshgrid(retinalPreferences, eyePreferences);
    
    % Network Parameters
    learningrate = 0.001;
    numEpochs = 1000;
    
    [inputPatterns, outputPatterns] = generatePatterns();
    
    % Create network
    untrainedNet = feedforwardnet([]);
    %net = newff(repmat([0 1], numInputNeurons, 1), 1, 'sig', 'trainlm', 'learngdm', 'mse');
    
    % Setup Training
    untrainedNet.trainParam.epochs = numEpochs;
    untrainedNet.trainParam.goal = 0.01;	
    untrainedNet.trainParam.lr = learningrate;
    untrainedNet.trainParam.show = 1;
    untrainedNet.trainParam.time = 1000;
    
    %{
    % Train over multiple trials
    %numTrials = 10;
    %numBins = 15;
    %histVector = zeros(numTrials, numBins);
    %for t=1:numTrials,
        
        %[trainedNet, tr] = train(untrainedNet, inputPatterns, outputPatterns);
        %histVector(t,:) = hist(trainedNet.IW{1},numBins);
        
    %end
    
    % Process data
    %means = mean(histVector);
    %stdev = std(histVector);
    %}
    
    % Train
    [trainedNet, tr] = train(untrainedNet, inputPatterns, outputPatterns);
    synapses = trainedNet.IW{1};
    
    % Figure
    figure();
    hist(synapses, 15);
    %errorbar(means,stdev);
    %ymax = max(h)*1.1;
    %ylim([0 ymax]);
    axis tight;
    %plot(m*[1 1], [0 ymax],'r-');
    hXLabel = xlabel('Synaptic Weight');
    hYLabel = ylabel('Frequency');
    
    disp(['Number of Inhibitory: ' num2str(nnz(synapses < 0))]);
    
    set( gca                   , ...
        'FontName'   , 'Helvetica' , ...
        'FontSize'   , 10          );
    
    set([ hXLabel, hYLabel], ...
        'FontName'   , 'AvantGarde');

    set(hYLabel  , ...
        'FontSize'   , 18          );
    set(hXLabel  , ...
        'FontSize'   , 18          );

    set(gca, ...
      'Box'         , 'on'     , ...
      'TickDir'     , 'in'     , ...
      'TickLength'  , [.02 .02] , ...
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'LineWidth'   , 2         );
  
    % Generate stimuli
    function [inputPatterns, outputPatterns] = generatePatterns()

        inputPatterns = zeros(numInputNeurons, numPatterns);
        outputPatterns = zeros(numOutputNeurons, numPatterns);
        
        % Iterate all targets comboes
        counter = 1;
        for r=retinalTargets,
            for e=eyeTargets,
                
                h = r+e;
                
                v = exp(-(r - retMesh).^2/(2*inputSigma^2)) .* 1./(1 + exp(sigmoidSlope * (eyeMesh - e)));
                %v = exp(-(r - retMesh).^2/(2*inputSigma^2)) .* exp(-(eyeMesh - e).^2/(2*inputSigma^2));
                
                %imagesc(v);
                
                inputPatterns(:,counter) = v(:);
                
                outputPatterns(:,counter) = exp(-((h - outputHeadPreferences).^2)/(2*outputSigma^2));
                
                counter = counter + 1;
            end
        end

    end

end