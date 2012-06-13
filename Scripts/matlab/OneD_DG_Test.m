%
%  OneD_DG_Test.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: Generate testing data
%

function OneD_DG_Test(stimuliName, samplingRate, fixationDuration, visualFieldSize, eyePositionFieldSize, targets, eyePositions)

    % Import global variables
    declareGlobalVars();
    
    global base;

    % Make folder
    stimuliFolder = [base 'Stimuli/' stimuliName '-stdTest'];
    
    if ~isdir(stimuliFolder),
        mkdir(stimuliFolder);
    end
    
    %if nargin < 8,
    %    iterateEyeWise = true;
    %end
        
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
   
    % The ordering of these two loops
    % controls interpretation of nrOfEyePositionsInTesting
    % Output data sequence for each target
    %if iterateEyeWise,
        
        for e = eyePositions,
            for t = targets,
                outputSample(e,t)
            end
        end
    %else
    %    
    %    for t = targets,
    %        for e = eyePositions,
    %            outputSample(e,t)
    %        end
    %    end
    %end

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
    info.targets = targets;
    info.eyePositions = eyePositions;
    info.testingStyle = 'stdTest';
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