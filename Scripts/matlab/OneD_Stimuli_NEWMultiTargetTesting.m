%
%  OneD_Stimuli_MultiTargetTesting.m
%  SMI
%
%  Created by Bedeho Mender on 18/11/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  Purpose: Generate testing data with multiple simultanous targets
%

function OneD_Stimuli_NEWMultiTargetTesting(stimuliName, samplingRate, fixationDuration, visualFieldSize, eyePositionFieldSize, testingEyePositions, testingTargets, numberOfSimultanousTargetsDuringTesting)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Make folder
    stimuliFolder = [base 'Stimuli/' stimuliName '-multiTest'];
    
    if ~isdir(stimuliFolder),
        mkdir(stimuliFolder);
    end
    
    %testingTargets = testingTargets(1:10:end);
    numTargets = length(testingTargets);
        
    % Derived
    timeStep                    = 1/samplingRate;
    samplesPrLocation           = uint32(ceil(fixationDuration/timeStep));
    
    % Open file
    filename = [stimuliFolder '/data.dat'];
    fileID = fopen(filename,'w');

    % Make header
    fwrite(fileID, samplingRate, 'ushort');                            % Rate of sampling
    fwrite(fileID, numberOfSimultanousTargetsDuringTesting, 'ushort'); % Number of simultanously visible targets, needed to parse data
    fwrite(fileID, visualFieldSize, 'float');
    fwrite(fileID, eyePositionFieldSize, 'float');
    
    targetLocations = zeros(1,numberOfSimultanousTargetsDuringTesting);
    
    % Genrate Data
    for e=testingEyePositions,
        doRecursion(1);
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
    info.numberOfSimultanousTargetsDuringTesting = numberOfSimultanousTargetsDuringTesting;
    
    % Save info
    save('info.mat','info');

    cd(startDir);
    
    function doRecursion(targetPos)
        
        % If we are at end of 
        if targetPos > numberOfSimultanousTargetsDuringTesting,
            outputSample(fileID, e, targetLocations - e, samplesPrLocation);
        else
            % Move target
            for j=1:numTargets,
                
                targetLocations(targetPos) = testingTargets(targetPos);
                
                % Next step!!
                doRecursion(targetPos+1);
            end
        end
    end

end