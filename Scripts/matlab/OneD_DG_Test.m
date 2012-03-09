%
%  OneD_DG_Test.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: Generate testing data
%

function OneD_DG_Test(stimuliName, targetBoundary, visualFieldSize, eyePositionFieldSize)

    % Import global variables
    declareGlobalVars();
    
    global base;

    % Make folder
    stimuliFolder = [base 'Stimuli/' stimuliName '-stdTest'];
    
    if ~isdir(stimuliFolder),
        mkdir(stimuliFolder);
    end
    
    % General
    %nrOfVisualTargetLocations   = 4;
    nrOfTestingTargets          = 10;
    nrOfEyePositions            = 4;
    samplingRate                = 10;	% (Hz)
    fixationDuration            = 0.2;	% (s) - fixation period after each saccade
    
    % Derived
    timeStep                    = 1/samplingRate;
    samplesPrLocation           = fixationDuration / timeStep;
    
    %%targets                     = centerN(visualFieldSize, nrOfTestingTargets);
    targets                     = centerN(2*targetBoundary, nrOfTestingTargets);
    %eyePositionFieldSize        = visualFieldSize - targets(end) % Make sure eye movement range is sufficiently confined to always keep any target on retina
    eyePositions                = centerN(eyePositionFieldSize, nrOfEyePositions);
    
    % Open file
    filename = [stimuliFolder '/data.dat'];
    fileID = fopen(filename,'w');

    % Make header
    fwrite(fileID, samplingRate, 'ushort');               % Rate of sampling
    fwrite(fileID, 1, 'ushort');                          % Number of simultanously visible targets, needed to parse data
    fwrite(fileID, visualFieldSize, 'float');
    fwrite(fileID, eyePositionFieldSize, 'float');
   
    % Output data sequence for each target
    for e = eyePositions,
        for t = targets,
            for sampleCounter = 1:samplesPrLocation,
            
                %disp(['Saved: eye =' num2str(e) ', ret =' num2str(t - e)]); % head centered data outputted, relationhip is t = r + e
                fwrite(fileID, e, 'float'); % Eye position (HFP)
                fwrite(fileID, t - e, 'float'); % Fixation offset of target
            end
            
            %disp('object done*******************');
            fwrite(fileID, NaN('single'), 'float'); % transform flag
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
    
    % Save stats
    info.nrOfEyePositionsInTesting = nrOfEyePositions;
    info.testingStyle = 'stdTest';
    save info;

    cd(startDir);
    
end