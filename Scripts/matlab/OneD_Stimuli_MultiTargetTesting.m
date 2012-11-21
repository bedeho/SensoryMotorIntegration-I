%
%  OneD_Stimuli_MultiTargetTesting.m
%  SMI
%
%  Created by Bedeho Mender on 18/11/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  Purpose: Generate testing data with multiple simultanous targets
%

function OneD_Stimuli_MultiTargetTesting(stimuliName, samplingRate, fixationDuration, visualFieldSize, eyePositionFieldSize, testingEyePositions, testingTargets, numberOfSimultanousTargetsDuringTesting)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Make folder
    stimuliFolder = [base 'Stimuli/' stimuliName '-multiTest'];
    
    if ~isdir(stimuliFolder),
        mkdir(stimuliFolder);
    end
    
    testingTargets = testingTargets(1:10:end);
        
    % Derived
    timeStep                    = 1/samplingRate;
    samplesPrLocation           = uint32(ceil(fixationDuration/timeStep));
    allTargetCombinations       = combnk(1:length(testingTargets), numberOfSimultanousTargetsDuringTesting);
    
    % Open file
    filename = [stimuliFolder '/data.dat'];
    fileID = fopen(filename,'w');

    % Make header
    fwrite(fileID, samplingRate, 'ushort');               % Rate of sampling
    fwrite(fileID, numberOfSimultanousTargetsDuringTesting, 'ushort'); % Number of simultanously visible targets, needed to parse data
    fwrite(fileID, visualFieldSize, 'float');
    fwrite(fileID, eyePositionFieldSize, 'float');
    
    % Make data
    for e = testingEyePositions,
        for t = 1:length(allTargetCombinations),
            outputSample(fileID, e, testingTargets(allTargetCombinations(t,:)), samplesPrLocation);
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
    info.allTargetCombinations = allTargetCombinations;
    info.numberOfSimultanousTargetsDuringTesting = numberOfSimultanousTargetsDuringTesting;
    
    % Save info
    save('info.mat','info');

    cd(startDir);

end