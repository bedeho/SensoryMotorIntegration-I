%
%  OneD_Stimuli_InputLayer.m
%  SMI
%
%  Created by Bedeho Mender on 27/01/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function v = OneD_Stimuli_InputLayer(pattern, visualPreferences, eyePositionPreferences, gaussianSigma, sigmoidSlope)

    % Allocate space
    nrOfVisualPreferences = length(visualPreferences);
    nrOfEyePositionPrefrerence = length(eyePositionPreferences);

    % v(1,x,y) - sigmoid positive
    % v(2,x,y) - sigmoid negative
    v = zeros(2, nrOfVisualPreferences, nrOfEyePositionPrefrerence);

    retinalPositions = pattern(2:end);
    eyePosition = pattern(1);
    
    % not in the matlab spirit, but I could not figure it out <== HAve code
    % somwhere else for this, completely vectorized!
    for i = 1:nrOfVisualPreferences,

        x = visualPreferences((nrOfVisualPreferences + 1) - i); % flip it so that the top row prefers the right most retinal loc.

        for j = 1:nrOfEyePositionPrefrerence,

            e = eyePositionPreferences(j);

            % visual component
            % Add up incase we have multiple targets
            v(1,i,j) = sum(exp(-(retinalPositions - x).^2/(2*gaussianSigma^2))); 
            v(2,i,j) = sum(exp(-(retinalPositions - x).^2/(2*gaussianSigma^2)));

            % SIGMOID eye modulation
            %v(1,i,j) = v(1,i,j) * 1/(1 + exp(sigmoidSlope * (eyePosition - e))); % positive slope
            %v(2,i,j) = v(2,i,j) * 1/(1 + exp(-1 * sigmoidSlope * (eyePosition - e))); % negative slope
        
            % GAUSSIAN eye modulation
            v(1,i,j) = v(1,i,j) * exp(-(eyePosition - e).^2/(2*gaussianSigma^2)); % positive slope
            v(2,i,j) = v(2,i,j) * exp(-(eyePosition - e).^2/(2*gaussianSigma^2)); % negative slope

        end
    end
           
end