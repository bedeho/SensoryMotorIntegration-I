%
%  OneD_Visualize.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: visualizes 1d data
%

function OneD_Visualize(stimuliName)
  
    % Exporting
    global OneD_VisualizeTimeObject; 
    global buffer;                  
    global lineCounter;                          
    global nrOfObjectsFoundSoFar;
    global timeStep;
    global fig;
    global numberOfSimultanousObjects;

    global dimensions;
    dimensions = OneD_DG_Dimensions();

    % Load file
    [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Load(stimuliName);
    
    % Init
    lineCounter = 1;
    nrOfObjectsFoundSoFar = 0;
    fig = figure();
    playAtPrcntOfOriginalSpeed = 1;                 % Parameters
    timeStep = 1/samplingRate;                      % Derived
    period = timeStep / playAtPrcntOfOriginalSpeed; % Derived
    
    %OneD_Visualize_TimerFcn('', '')
     
    
    % Setup timer
    % Good video on timers: http://blogs.mathworks.com/pick/2008/05/05/advanced-matlab-timer-objects/
    OneD_VisualizeTimeObject = timer('Period', period, 'ExecutionMode', 'fixedSpacing');
    set(OneD_VisualizeTimeObject, 'TimerFcn', {@OneD_Visualize_TimerFcn});
    set(OneD_VisualizeTimeObject, 'StopFcn', {@OneD_Visualize_StopFcn});

    % Start timer
    start(OneD_VisualizeTimeObject);
    
     
end