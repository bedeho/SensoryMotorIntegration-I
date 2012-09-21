%
%  pouget.m
%  SMI
%
%  Created by Bedeho Mender on 21/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function pouget()

    % Network Parameters
    numInputNeurons = 10;
    numOutputNeurons = 10;
    learningrate = 0.001;
    %sigmoidSlope = 1.0;

    % Training Paramters
    numEpochs = 1000;
    
    % Stimuli Parametsr
    numPatterns = 10;
    
    [inputPatterns, outputPatterns] = generateInputOutputPatterns(numPatterns, numInputNeurons, numOutputNeurons);

    % Create network
    net = newff(repmat([0 1], numOutputNeurons, 1), numOutputNeurons, 'sig', 'trainlm', 'learngdm', 'mse');
    
    % Initialize nets weigting biases
    net = init(net);
    
    % Training
    net.trainParam.epochs = numEpochs;
    net.trainParam.goal = 0.01;	
    net.trainParam.lr = learningrate;
    net.trainParam.show = 1;
    net.trainParam.time = 1000;
    
    % Train
    train(net, inputPatterns, outputPatterns);

end