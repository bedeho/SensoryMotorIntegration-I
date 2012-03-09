%
%  OneD_DG_TestOnTrained.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: Generates testing data which tests in exactly the training
%  positions and which makes the result of this test in the appropriate
%  format for the analysis scripts.
%

function OneD_DG_TestOnTrained(stimuliName)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Movement parameters
    fixationDuration = 0.5; % (s) 0
    simulatorTimeStepSize = 0.1*0.5
    
    % Make folder
    %str = strsplit(stimuliName,'-');
    str = strrep(stimuliName, '-training', '')
    stimuliFolder = [base 'Stimuli/' str '-testOnTrained'];
    if ~isdir(stimuliFolder),
        mkdir(stimuliFolder);
    end
    
    % Load file
    [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Load(stimuliName);
    
    ticksPrSample = fixationDuration * samplingRate;
    
    if(ticksPrSample < 1) 
        error(['ticksPrSample < 1' ticksPrSample]);
    end
    
    % Parse data
    [objects, minSequenceLength, objectsFound] = OneD_Parse(buffer);
    objectDuration = minSequenceLength/samplingRate;
    nrOfModelTicks = floor(objectDuration/simulatorTimeStepSize);
    
    %% Use as nrOfEyePositionsInTesting in analysis
    %%nrOfEyePositionsInTesting = num2str(minSequenceLength)
    
    % Open file
    filename = [stimuliFolder '/data.dat'];
    fileID = fopen(filename,'w');

    % Make header
    numberOfSimultanousObjects = 1;

    fwrite(fileID, samplingRate, 'ushort');               % Rate of sampling
    fwrite(fileID, numberOfSimultanousObjects, 'ushort'); % Number of simultanously visible targets, needed to parse data
    fwrite(fileID, visualFieldSize, 'float');
    fwrite(fileID, eyePositionFieldSize, 'float');
    
    % Output data sequence for each target
    nrOfCleanedUpPointsFound = 0;
    for o = 1:objectsFound,
        
        % Compute what model sees
        data = linearInterpolate(objects{o});
        
        % Remove redundancy
        cleanedUp = unique(data,'rows');
        x = length(cleanedUp);
        
        if o > 1 && nrOfCleanedUpPointsFound ~= x,
            warning('Number of cleaned up points vary');
        end
        
        nrOfCleanedUpPointsFound = x;
        
        % For each unique data point output stream
        for s = cleanedUp',
            
            % Duplicat sample and write out duplicates in column order
            repeatedSample = repmat(s,1,ticksPrSample);
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
    
    % Save stats
    info.nrOfEyePositionsInTesting = objectsFound;
    info.testingStyle = 'testOnTrained';
    save('info.mat','info');
    
    cd(startDir);
    
    function data = linearInterpolate(samples)
        
        dim = size(samples);
        sampleDimension = dim(2);
        
        data = zeros(nrOfModelTicks+1,2);
        
        dx = (1/samplingRate);
        
        %go through 'samples' at steps of 'simulatorTimeStepSize'
        %interpolate points.
        for t = 0:nrOfModelTicks, % start at 0 because that is where the model starts
           
            time = (t * simulatorTimeStepSize);
            streamPoint = (time / dx);
            startPoint = floor(streamPoint); % this should in theory never be last sample point
            overflow = streamPoint - startPoint;
            
            startPoint = startPoint + 1; % 1 based indexing.
            
            if startPoint < length(samples), % check if we are on the last point
                
                for i = 1:sampleDimension,
                    
                    dy = samples(startPoint + 1,i) - samples(startPoint,i);
                    slope = dy/dx;
                    intercept = samples(startPoint,i);
                    f = intercept + slope*overflow; 
                    
                    val(i) = str2double(sprintf('%.1f',f));
                end
            else
                val = samples(end,:);
            end
            
            data(t+1,:) = val;
        end
        
    end
    
end