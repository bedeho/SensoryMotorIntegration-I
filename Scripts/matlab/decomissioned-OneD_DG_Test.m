%
%  OneD_DG_Test.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: Generate testing data
%

function OneD_DG_Test(stimuliName, samplingRate, fixationDuration, dimensions, eyePositions, testingStyle)


    error('decomissioned');

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Get args
    visualFieldSize = dimensions.visualFieldSize, 
    eyePositionFieldSize = dimensions.eyePositionFieldSize
    targets = dimensions.targets;
    visualPreferences = dimensions.visualPreferences;
    eyePositionPreferences = dimensions.eyePositionPreferences;
    
    % Make folder
    stimuliFolder = [base 'Stimuli/' stimuliName '-stdTest'];
    
    if ~isdir(stimuliFolder),
        mkdir(stimuliFolder);
    end
        
    % Derived
    timeStep                    = 1/samplingRate;
    samplesPrLocation           = fixationDuration / timeStep;
        
    % Open file
    filename = [stimuliFolder '/data.dat'];
    fileID = fopen(filename,'w');

    % Make header
    fwrite(fileID, samplingRate, 'ushort');               % Rate of sampling
    fwrite(fileID, 1, 'ushort');                          % Number of simultanously visible targets, needed to parse data
    fwrite(fileID, visualFieldSize, 'float');
    fwrite(fileID, eyePositionFieldSize, 'float');
    
    % Save relevant information for post processing
    info.testingStyle = testingStyle;
    info.visualPreferences = visualPreferences;
    info.eyePositionPreferences = eyePositionPreferences;
    
    if strcmp(testingStyle,'old'),
        
        for e = eyePositions,
            for t = targets,
                outputSample(e,t)
            end
        end
        
        % For post processing
        info.targets = targets;
        info.eyePositions = eyePositions;
        
    else
        
        % Had bugs here, assuming order!! 
        trainingEyePositionFieldSize = max(eyePositions)*2;
        trainingTargetFieldSize = max(targets)*2;
        
        testingEyePositions = centerN2(trainingEyePositionFieldSize, 10); % eyePositionFieldSize
        testingTargets = centerN2(trainingTargetFieldSize, 20); % dimensions.visualFieldEccentricity

        for e = testingEyePositions,
            for t = testingTargets,
                outputSample(e,t)
            end
        end
        
        % For post processing
        info.targets = testingTargets;
        info.eyePositions = testingEyePositions;
    
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
    
    % Save info
    save info;

    cd(startDir);
    
    function outputSample(e,t)
        
        for sampleCounter = 1:samplesPrLocation,

            %disp(['Saved: eye =' num2str(e) ', ret =' num2str(t - e)]); % head centered data outputted, relationhip is t = r + e
            fwrite(fileID, e, 'float'); % Eye position (HFP)
            fwrite(fileID, t - e, 'float'); % Fixation offset of target
        end

        %disp('object done*******************');
        fwrite(fileID, NaN('single'), 'float'); % transform flag

    end
    
end