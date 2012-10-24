%
%  OneD_DG_Dimensions.m
%  SMI
%
%  Created by Bedeho Mender on 27/01/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function dimensions = OneD_DG_Dimensions()

    % Stimuli
    M = 8;
    dimensions.nrOfVisualTargetLocations  = M;
    dimensions.numberOfSimultanousObjects = 1;
    
    % Enviroment (non-Elmsley) 
    dimensions.visualFieldSize             = 200; % Entire visual field (rougly 100 per eye), (deg)
    dimensions.targetRangeProportionOfVisualField = 0.5;
    dimensions.visualFieldEccentricity     = dimensions.visualFieldSize * dimensions.targetRangeProportionOfVisualField;
    
    % Elmsley eye model
    % DistanceToScreen          = ;     % Eye centers line to screen distance (meters)
    % Eyeball                   = ;     % Radius of each eyeball (meters)
    % EyeSpacing                = ;     % Half eye center distance (meters)
    % OnScreenTargetSpacing     = ;     % On screen target distance (meters)

    % LIP Parameters
    
    %% Sejnowski:   8,6,18,1/16
    dimensions.visualPreferenceDistance = 1;
    dimensions.eyePositionPrefrerenceDistance = 1;
    dimensions.gaussianSigma = 18; % deg
    dimensions.sigmoidSlope = 1/16; % (1/8)/2; % num
    
    %% Modified:
    %dimensions.visualPreferenceDistance = 1;
    %dimensions.eyePositionPrefrerenceDistance = 1;
    %dimensions.gaussianSigma = 6; % deg
    %dimensions.sigmoidSlope = 1/16 % (1/8)/2; % num
    
    % Dump to screen
    dimensions
    
    % Place targets
    if dimensions.nrOfVisualTargetLocations > 1,
        dimensions.targets = centerN2(dimensions.visualFieldEccentricity , dimensions.nrOfVisualTargetLocations);
        dimensions.targetBoundary = dimensions.targets(end);
    else
        dimensions.targets = 0;
        dimensions.targetBoundary = 10;
    end
    
    % dimensions.targetBoundary = eccentricity of most extreme target in head space
    
    % Derive eye movement range is sufficiently confined to keep ANY
    % target on retina
    dimensions.eyePositionFieldSize = dimensions.visualFieldSize - 2*dimensions.targets(end);
    %dimensions.eyePositionEccentricity = dimensions.eyePositionFieldSize/2;
    dimensions.leftMostEyePosition = -dimensions.eyePositionFieldSize/2;
    dimensions.rightMostEyePosition = dimensions.eyePositionFieldSize/2; 
    
    % Retina
    dimensions.leftMostVisualPosition = -dimensions.visualFieldSize/2;
    dimensions.rightMostVisualPosition = dimensions.visualFieldSize/2;    
    
    % Place LIP preference in retinal/eye position domain
    dimensions.visualPreferences = centerDistance(dimensions.visualFieldSize, dimensions.visualPreferenceDistance);
    dimensions.eyePositionPreferences = centerDistance(dimensions.eyePositionFieldSize, dimensions.eyePositionPrefrerenceDistance);
    
    dimensions.nrOfVisualPreferences = length(dimensions.visualPreferences);
    dimensions.nrOfEyePositionPrefrerence = length(dimensions.eyePositionPreferences);

    
end