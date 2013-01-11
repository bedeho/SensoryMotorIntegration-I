%
%  OneD_Stimuli_Visualize.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function OneD_Stimuli_Visualize(stimuliName, visualPreferenceDistance, eyePositionPrefrerenceDistance)

    % Import global variables
    declareGlobalVars();
    
    global base;
  
    % Exporting
    global OneD_Stimuli_VisualizeTimeObject; 
    global buffer;                  
    global lineCounter;                          
    global nrOfObjectsFoundSoFar;
    global timeStep;
    global fig;
    
    % Load supplementary stimuli dimensions
    path = [base 'Stimuli/' stimuliName];
    startDir = pwd;
    cd(path);
    dimensions = load('dimensions.mat');
    cd(startDir);

    % LIP Parameters   
    gaussianSigma                       = 6; % deg
    sigmoidSlope                        = 1/16; % (1/8)/2 = 0.0625
    
    visualPreferences                   = centerDistance(dimensions.visualFieldSize, visualPreferenceDistance);
    eyePositionPreferences              = centerDistance(dimensions.eyePositionFieldSize, eyePositionPrefrerenceDistance);

    % Load data
    [samplingRate, numberOfSimultanousTargets, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Stimuli_Load(stimuliName);
    
    % Init
    lineCounter = 1;
    nrOfObjectsFoundSoFar = 0;
    fig = figure();
    playAtPrcntOfOriginalSpeed = 1;                 % Parameters
    timeStep = 1/samplingRate;                      % Derived
    period = timeStep / playAtPrcntOfOriginalSpeed; % Derived
    
    % Setup timer
    % Good video on timers: http://blogs.mathworks.com/pick/2008/05/05/advanced-matlab-timer-objects/
    OneD_Stimuli_VisualizeTimeObject = timer('Period', period, 'ExecutionMode', 'fixedSpacing');
    set(OneD_Stimuli_VisualizeTimeObject, 'TimerFcn', {@OneD_Stimuli_Visualize_TimerFcn, numberOfSimultanousTargets, visualPreferences, eyePositionPreferences, gaussianSigma, sigmoidSlope, dimensions, timeStep});
    set(OneD_Stimuli_VisualizeTimeObject, 'StopFcn', {@OneD_Stimuli_Visualize_StopFcn});

    % Start timer
    start(OneD_Stimuli_VisualizeTimeObject);
    
end