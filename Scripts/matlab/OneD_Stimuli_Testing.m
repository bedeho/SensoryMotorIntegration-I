%
%  OneD_Stimuli_Testing.m
%  SMI
%
%  Created by Bedeho Mender on 06/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  Purpose: Generate testing data
%

function OneD_Stimuli_Testing(stimuliName, samplingRate, fixationDuration, visualFieldSize, eyePositionFieldSize, testingEyePositions, testingTargets)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Make folder
    stimuliFolder = [base 'Stimuli/' stimuliName '-stdTest'];
    
    if ~isdir(stimuliFolder),
        mkdir(stimuliFolder);
    end
        
    % Derived
    timeStep                    = 1/samplingRate;
    samplesPrLocation           = uint32(ceil(fixationDuration/timeStep));
        
    % Open file
    filename = [stimuliFolder '/data.dat'];
    fileID = fopen(filename,'w');

    % Make header
    fwrite(fileID, samplingRate, 'ushort');               % Rate of sampling
    fwrite(fileID, 1, 'ushort');                          % Number of simultanously visible targets, needed to parse data
    fwrite(fileID, visualFieldSize, 'float');
    fwrite(fileID, eyePositionFieldSize, 'float');
    
    % Make data
    for e = testingEyePositions,
        for t = testingTargets,
            outputSample(fileID, e, t, samplesPrLocation);
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

end