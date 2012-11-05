%
%  OneD_Visualize.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function OneD_Visualize(stimuliName)
  
    % Exporting
    global OneD_VisualizeTimeObject; 
    global buffer;                  
    global lineCounter;                          
    global nrOfObjectsFoundSoFar;
    global timeStep;
    global fig;
    
    global dimensions;
    global visualPreferenceDistance;
    
    % Load supplementary stimuli dimensions
    [stimuliFolder, name, ext] = fileparts(stimuliName);
    startDir = pwd;
    cd(stimuliFolder);

    dimensions = load('dimensions.mat');

    cd(startDir);
    dimensions = ... OneD_DG_Dimensions();




    % LIP Parameters
    visualPreferenceDistance            = 1;
    eyePositionPrefrerenceDistance      = 1;
    
    gaussianSigma                       = 18; % deg
    sigmoidSlope                        = 1/16; % (1/8)/2; % num
    
    visualPreferences                   = centerDistance(visualFieldSize, visualPreferenceDistance);
    eyePositionPreferences              = centerDistance(eyePositionFieldSize, eyePositionPrefrerenceDistance);






















    % Load data
    [samplingRate, numberOfSimultanousTargets, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Load(stimuliName);
    
    % Init
    lineCounter = 1;
    nrOfObjectsFoundSoFar = 0;
    fig = figure();
    playAtPrcntOfOriginalSpeed = 1;                 % Parameters
    timeStep = 1/samplingRate;                      % Derived
    period = timeStep / playAtPrcntOfOriginalSpeed; % Derived
    
    % Setup timer
    % Good video on timers: http://blogs.mathworks.com/pick/2008/05/05/advanced-matlab-timer-objects/
    OneD_VisualizeTimeObject = timer('Period', period, 'ExecutionMode', 'fixedSpacing');
    set(OneD_VisualizeTimeObject, 'TimerFcn', {@OneD_Visualize_TimerFcn});
    set(OneD_VisualizeTimeObject, 'StopFcn', {@OneD_Visualize_StopFcn});

    % Start timer
    start(OneD_VisualizeTimeObject);
    
     
end