%
%  pouget.m
%  SMI
%
%  Created by Bedeho Mender on 21/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function pouget()

    % A. Pouget & T. Sejnowski (1997)
    
    % Input:
    % 121 units
    % \mu uniform in 12 increments \in [-60,60]
    % \sigma = 18
    % \inflection points uniform in 8 increments \in [-40,40]
    % slope = 8
    retinalPreferences = centerDistance(60*2, 12);
    eyePreferences = centerDistance(40*2, 8);
    
    [retMesh,eyeMesh] = meshgrid(retinalPreferences, eyePreferences);
    
    % Output 
    % 1 unit
    % \sigma = 18
    % \mu = 0
    outputSigma = 18;
    outputMu = 0;
    
    % Stimuli 
    % 441=21*21 pairs of retinal and eye positions.
    % 21 retinal locations in [-40,40]
    % 21 eye positions in [-20,20]
    retinalTargets = centerN(80, 21);
    eyeTargets = centerN(40, 21);
    
    [retTargetMesh,eyeTargetMesh] = meshgrid(retinalPreferences, eyePreferences);
    
    
    
    % Network Parameters
    numInputNeurons = length(retinalPreferences);
    learningrate = 0.001;
    numEpochs = 1000;
    
    [inputPatterns, outputPatterns] = generatePatterns(numPatterns, numInputNeurons, numOutputNeurons);

    % Create network
    net = newff(repmat([0 1], numOutputNeurons, 1), 1, 'sig', 'trainlm', 'learngdm', 'mse');
    
    % Initialize nets weigting (random: will produce varying results)
    net = init(net);
    
    % Setup Training
    net.trainParam.epochs = numEpochs;
    net.trainParam.goal = 0.01;	
    net.trainParam.lr = learningrate;
    net.trainParam.show = 1;
    net.trainParam.time = 1000;
    
    % Train
    train(net, inputPatterns, outputPatterns);
    
    % Test
    test = sim(net, inputPatterns);
    
    % Generate stimuli
    function [inputPatterns, outputPatterns] = generatePatterns(numPatterns, numInputNeurons, numOutputNeurons)

        
        
        
        %inputPatterns = rand(numInputNeurons, numPatterns);
        %outputPatterns = rand(1, numPatterns);

    end

end