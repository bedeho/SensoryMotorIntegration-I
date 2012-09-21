%
%  basisfunction.m
%  SMI
%
%  Created by Bedeho Mender on 21/09/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function basisfunction()

    % Network Parameters
    numInputNeurons = 10;
    numOutputNeurons = 10;
    learningrate = 0.1;
    sigmoidSlope = 1.0;

    weightMatrix = rand(numOutputNeurons,numInputNeurons);

    % Stimuli Parametsr
    numPatterns = 10;

    % Generate stimuli
    [inputPatterns, outputPatterns] = generateInputOutputPatterns(numPatterns, numInputNeurons, numOutputNeurons);

    % Keeps errors of last epoch
    lastEpochErrors = ones(1,numOutputNeurons);
    thisEpochErrors = 2*ones(1,numOutputNeurons);

    % While last epoch has smaller errors thanthis
    numEpochs = 0;
    while any(lastEpochErrors < thisEpochErrors),

        % Epoch: Iterate each pattern
        for p=1:numPatterns,

            % Get pattern 
            input = inputPatterns(:,p);
            output = outputPatterns(:,p);

            % Compute activation
            activations = weightMatrix*input;

            % Compute firing
            firings = activations;

            % Upate weights: f(x) = x, implies f'(x) = 1,
            % dw = learningrate*(firing - desiredOutput)*input
            weightMatrix = weightMatrix + learningrate*(repmat(firings, 1, numInputNeurons).*repmat(input, 1, numOutputNeurons) - repmat(output, 1, numOutputNeurons))*input;

        end

        % Compute new error
        responseToAllPatterns = weightMatrix*inputPatterns;
        thisEpochErrors = sum((responseToAllPatterns - outputPatterns).^2);

        % Increase epoch counter
        numEpochs = numEpochs + 1;

        % Display progress
        disp(['Epoch #' num2str(numEpochs) ': ' num2str(thisEpochErrors)]);
    end

    disp('Done.');

    function [inputPatterns, outputPatterns] = generateInputOutputPatterns(numPatterns, numInputNeurons, numOutputNeurons)

        inputPatterns = rand(numInputNeurons, numPatterns);
        outputPatterns = rand(numOutputNeurons, numPatterns);

    end

end