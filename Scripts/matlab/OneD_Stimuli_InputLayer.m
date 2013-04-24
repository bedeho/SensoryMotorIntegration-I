%
%  OneD_Stimuli_InputLayer.m
%  SMI
%
%  Created by Bedeho Mender on 27/01/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
function v = OneD_Stimuli_InputLayer(pattern, doSigmoid, visualPreferences, eyePositionPreferences, gaussianSigma, sigmoidSlope)

    % Get 
    retinalPositions = pattern(2:end);
    eyePosition = pattern(1);
    
    %% vectorized
    [X,Y] = meshgrid(eyePositionPreferences, visualPreferences);
    
    % reverse direction
    Y = flipud(Y);
    
    if doSigmoid,
        pos_sigma = (1./(1 + exp(-1*sigmoidSlope*(eyePosition - X)))).*exp(-1*(retinalPositions - Y).^2/(2*gaussianSigma^2));
        neg_sigma = (1./(1 +    exp(sigmoidSlope*(eyePosition - X)))).*exp(-1*(retinalPositions - Y).^2/(2*gaussianSigma^2));
        
        v = cat(3, pos_sigma, neg_sigma);
    
        v = permute(v,[3 1 2]);
        
    else
        v = exp(-1*(eyePosition - X).^2/(2*gaussianSigma^2)).*exp(-1*(retinalPositions - Y).^2/(2*gaussianSigma^2));
    end



end