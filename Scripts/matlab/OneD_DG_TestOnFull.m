%
%  OneD_DG_TestOnFull.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: Generates testing data which tests in exactly the training
%  positions and which makes the result of this test in the appropriate
%  format for the analysis scripts.
%

function OneD_DG_TestOnFull(stimuliName, samplingRate, visualFieldSize, eyePositionFieldSize)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Resolution for test
    retinalStepSize = 20; % (deg)
    eyePositionStepSize = 15; % (deg) 20 was first
    
    % Movement parameters
    fixationDuration = 0.1; % (s)0
    
    stimuliFolder = [base 'Stimuli/' stimuliName '_TestOnFull'];
    
    % Make folder
    if ~isdir(stimuliFolder),
        mkdir(stimuliFolder);
    end
    
    % Open file
    filename = [stimuliFolder '/data.dat'];
    fileID = fopen(filename,'w');

    % Make header
    numberOfSimultanousObjects = 1;

    fwrite(fileID, samplingRate, 'ushort');               % Rate of sampling
    fwrite(fileID, numberOfSimultanousObjects, 'ushort'); % Number of simultanously visible targets, needed to parse data
    fwrite(fileID, visualFieldSize, 'float');
    fwrite(fileID, eyePositionFieldSize, 'float');
    
    ticksPrSample = fixationDuration * samplingRate;
    
    % Output data sequence for each target
    visualTargets = centerDistance(visualFieldSize, retinalStepSize);
    eyePositionTargets = centerDistance(eyePositionFieldSize, eyePositionStepSize);
    
    % Remove edges
    visualTargets = visualTargets(2:(end-1));
    eyePositionTargets = eyePositionTargets(2:(end-1));
    
    % Flip data to make it match visualizer better
    visualTargets = fliplr(visualTargets);
    
    for s = eyePositionTargets,
        for v = visualTargets,
            
            % Duplicat sample and write out duplicates in column order
            repeatedSample = repmat([s v]',1,ticksPrSample);
            fwrite(fileID, repeatedSample, 'float');
            
            % Inject transform stop
            fwrite(fileID, NaN('single'), 'float'); 
       end
    end

    % Close file
    fclose(fileID);
    
    % Create payload for xgrid
    startDir = pwd;
    cd(stimuliFolder);
    [status, result] = system('tar -cjvf xgridPayload.tbz data.dat');
    if status,
        error(['Could not create xgridPayload.tbz' result]);
    end
    cd(startDir);
    
end