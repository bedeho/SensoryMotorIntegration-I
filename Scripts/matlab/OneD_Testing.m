%
%  OneD_Testing.m
%  SMI
%
%  Created by Bedeho Mender on 06/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  Purpose: Generate testing data
%

function OneD_Testing(stimuliName, samplingRate, fixationDuration, visualFieldSize, eyePositionFieldSize, trainingEyePositionFieldSize, trainingTargetFieldSize, nrOfTestingEyePositions, nrOfRetinalTestingPositions)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Check arguments
    if trainingEyePositionFieldSize < nrOfTestingEyePositions,
        error('To many eye positions');
    elseif trainingTargetFieldSize < nrOfRetinalTestingPositions,
        error('To many retinal positions');
    end
    
    % Make folder
    stimuliFolder = [base 'Stimuli/' stimuliName '-stdTest'];
    
    if ~isdir(stimuliFolder),
        mkdir(stimuliFolder);
    end
        
    % Derived
    timeStep                    = 1/samplingRate;
    samplesPrLocation           = fixationDuration/timeStep;
        
    % Open file
    filename = [stimuliFolder '/data.dat'];
    fileID = fopen(filename,'w');

    % Make header
    fwrite(fileID, samplingRate, 'ushort');               % Rate of sampling
    fwrite(fileID, 1, 'ushort');                          % Number of simultanously visible targets, needed to parse data
    fwrite(fileID, visualFieldSize, 'float');
    fwrite(fileID, eyePositionFieldSize, 'float');
    
    % Make data
    testingEyePositions = centerN2(trainingEyePositionFieldSize, nrOfTestingEyePositions); % eyePositionFieldSize
    testingTargets = fliplr(centerN2(trainingTargetFieldSize, nrOfRetinalTestingPositions)); % 0.8* dimensions.visualFieldEccentricity

    for e = testingEyePositions,
        for t = testingTargets,
            outputSample(e,t)
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
    
    % For post processing
    info.targets = testingTargets;
    info.eyePositions = testingEyePositions;
    
    % Save info
    save('info.mat','info');

    cd(startDir);
    
    function outputSample(e, t)
        
        for sampleCounter = 1:samplesPrLocation,

            %disp(['Saved: eye =' num2str(e) ', ret =' num2str(t - e)]); % head centered data outputted, relationhip is t = r + e
            fwrite(fileID, e, 'float'); % Eye position (HFP)
            fwrite(fileID, t - e, 'float'); % Fixation offset of target
        end

        %disp('object done*******************');
        fwrite(fileID, NaN('single'), 'float'); % transform flag

    end
    
end