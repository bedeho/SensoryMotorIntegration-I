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
    fixationDuration = 0.050; % (s) 0
    timeConstant = input('Please enter timeConstant (e.g. 0.010):');
    stepSizeFraction = input('Please enter step size fraction for testOnTrained (e.g. 0.5):');
    simulatorTimeStepSize = timeConstant*stepSizeFraction;
    
    % Make folder
    %str = strsplit(stimuliName,'-');
    str = strrep(stimuliName, '-training', '')
    stimuliFolder = [base 'Stimuli/' str '-testOnTrained'];
    if ~isdir(stimuliFolder),
        mkdir(stimuliFolder);
    end
    
    % Load file
    [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Load(stimuliName);
    
    ticksPrSample = ceil(fixationDuration * samplingRate);
    
    if(ticksPrSample < 1) 
        error(['ticksPrSample < 1' ticksPrSample]);
    end
    
    % Parse data
    [objects, minSequenceLength, objectsFound] = OneD_Parse(buffer);
    objectDuration = minSequenceLength/samplingRate;
    nrOfModelTicksPerObjects = ceil(objectDuration/simulatorTimeStepSize); % Round up to not loose last sample (?)
    
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
    % Algorithm
    % 1. Take actual input datastrem for an object, and
    % step throug it using the model's ACTUAL timestep
    % and interpolation method (linear) to produce
    % new time stream which is IDENTICAL to what model
    % will see.
    % 2. Remove all redundancy from this stream
    % 3. Turn each of the resulting data points in this
    % stream into an object for which you generate the appropriate
    % number of samples based on the fixation duration parameter
    % for testing and the sampling rate being used.
    
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
        
        data = zeros(nrOfModelTicksPerObjects+1,2);
        
        dx = (1/samplingRate);
        
        %go through 'samples' at steps of 'simulatorTimeStepSize'
        %interpolate points.
        for t = 0:nrOfModelTicksPerObjects, % start at 0 because that is where the model starts
           
            % Actual model time of start of sample "t"
            presentModelTime = (t * simulatorTimeStepSize);
            
            % The number of full samples presentModelTime covers
            nrOfFullSamples = floor(presentModelTime / dx);
            
            % Time from startPoint time to presentModelTime
            if nrOfFullSamples == 0,
                overflow = 0;
            else
                overflow = rem(presentModelTime, nrOfFullSamples * dx);
            end
            
            % Sample point immediatly prior to presentModelTime
            startPoint = nrOfFullSamples + 1;
            
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