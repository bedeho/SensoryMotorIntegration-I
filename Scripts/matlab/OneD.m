%
%  OneD_DG_Random.m
%  SMI
%
%  Created by Bedeho Mender on 08/02/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  Purpose: Generates the simplest possible 1d dynamical data
%

function OneD_DG_Random_Simple(prefix)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Load enviromental paramters
    dimensions = OneD_DG_Dimensions();
    
    % Parameters
    saccadeVelocity             = 4000000000000000000000;	% (deg/s), http://www.omlab.org/Personnel/lfd/Jrnl_Arts/033_Sacc_Vel_Chars_Intrinsic_Variability_Fatigue_1979.pdf
    samplingRate                = 1000;	% (Hz)
    fixationDuration            = 0.050;  % 0.25;	% (s) - fixation period after each saccade
    saccadeAmplitude            = 90;    % 35= 13 hp(deg) - angular magnitude of each saccade, after which there is a fixation periode
    nrOfOrderings               = 1;

    % Derived
    ticksPrSample = fixationDuration * samplingRate;

    possibleEyePositions = dimensions.leftMostEyePosition:saccadeAmplitude:dimensions.rightMostEyePosition;
    nrOfEyePositions = length(possibleEyePositions);

    % No multiline concat... damn
    if nargin < 1,
        prefix = '';
    else
        prefix = [prefix '-']
    end
    
    encodePrefix = [prefix 'Tar=' num2str(dimensions.nrOfVisualTargetLocations,'%.2f')];
    encodePrefix = [encodePrefix '-Ord=' num2str(nrOfOrderings,'%.2f')];
    encodePrefix = [encodePrefix '-Sim=' num2str(dimensions.numberOfSimultanousObjects,'%.2f')];
    encodePrefix = [encodePrefix '-fD=' num2str(fixationDuration,'%.2f') ];
    encodePrefix = [encodePrefix '-sA=' num2str(saccadeAmplitude,'%.2f') ];
    encodePrefix = [encodePrefix '-vpD=' num2str(dimensions.visualPreferenceDistance,'%.2f')];
    encodePrefix = [encodePrefix '-epD=' num2str(dimensions.eyePositionPrefrerenceDistance,'%.2f')];
    encodePrefix = [encodePrefix '-gS=' num2str(dimensions.gaussianSigma,'%.2f')];
    encodePrefix = [encodePrefix '-sS=' num2str(dimensions.sigmoidSlope,'%.2f')];
    encodePrefix = [encodePrefix '-vF=' num2str(dimensions.visualFieldSize,'%.2f')];
    encodePrefix = [encodePrefix '-eF=' num2str(dimensions.eyePositionFieldSize,'%.2f')];
    tSFolderName = ['random-' encodePrefix];
    
    tSPath = [base 'Stimuli/' tSFolderName '-training'];
    
    % Make folder
    if ~isdir(tSPath),
        mkdir(tSPath);
    end
    
    % Open file
    filename = [tSPath '/data.dat'];
    fileID = fopen(filename,'w');

    % Make header
    fwrite(fileID, samplingRate, 'ushort');               % Rate of sampling
    fwrite(fileID, dimensions.numberOfSimultanousObjects, 'ushort'); % Number of simultanously visible targets, needed to parse data
    fwrite(fileID, dimensions.visualFieldSize, 'float');
    fwrite(fileID, dimensions.eyePositionFieldSize, 'float');
   
    % Set index
    rng(72, 'twister');
    
    % Setup for generating target combinations
    n = dimensions.nrOfVisualTargetLocations;
    r = dimensions.numberOfSimultanousObjects;
    unsampledPerms = combnk(1:n, r);
    
    % Iterate target combinations
    while ~isempty(unsampledPerms),

        dim = size(unsampledPerms);
        sampleId = randi(dim(1));
        showTargets = unsampledPerms(sampleId,:);
        unsampledPerms(sampleId,:) = []; % Kill this combination
        
        % Output data sequence for each target
        targets = dimensions.targets(showTargets);
        
        % Output all samples for this target combination
        doTimeSteps(targets);
        
        fwrite(fileID, NaN('single'), 'float');         % transform flag
        
    end

    % Close file
    fclose(fileID);
    
    % Create payload for xgrid
    startDir = pwd;
    cd(tSPath);
    [status, result] = system('tar -cjvf xgridPayload.tbz data.dat');
    if status,
        error(['Could not create xgridPayload.tbz' result]);
    end
    
    % Save dimensions used
    save('dimensions.mat','dimensions');
    
    cd(startDir);
    
    % Generate complementary testing data
    OneD_DG_Test(tSFolderName, samplingRate, fixationDuration, dimensions.visualFieldSize, dimensions.eyePositionFieldSize, dimensions.targets, possibleEyePositions, false);
    
    % Generate correlation data
    OneD_DG_Correlation([tSFolderName '-stdTest']);
    
    % Visualize
    OneD_Overlay([tSFolderName '-training'],[tSFolderName '-stdTest'])
    
    function doTimeSteps(targets)
        
        for o=1:nrOfOrderings,
            
            eyePositionOrder = randperm(nrOfEyePositions)
            
            % Generate the cirtical points of the
            eyePositionsInOrder = possibleEyePositions(eyePositionOrder); % Translate eye position indexes into actual positions
            criticalPoints = generateCriticalPoints(eyePositionsInOrder);
            
            % Step through at given frequency and dump to file
            stepThroughAndOutput(criticalPoints);
              
        end
    end

    function points = generateCriticalPoints(order)
        
        %(time,eye_position,ret_1,...,ret_n)
        
        % Allocate space
        numberOfDataPoints = 2 * length(order); % start and end of each fixation
        dimensionOfDataPoints = 1 + 1 + length(dimensions.numberOfSimultanousObjects); % time + eye_position + ret_1,...,ret_n
        points = zeros(dimensionOfDataPoints, numberOfDataPoints);
        
        % Generate
        time = 0;
        
        % invariant: time is of next point in time
        for dataPoint = 1:length(order),
            
            % Eye position
            ep = order(dataPoint);
            
            % Retinal target locations
            retinalTargets = targets - ep;
            
            % Update and save state of fixation START
            state = [time ep retinalTargets];
            points(:,dataPoint*2-1) = state;
            
            % Add some time for end of fixation point
            time = time + fixationDuration;
            
            % Update and save state of fixation END
            state = [time ep retinalTargets];
            points(:,dataPoint*2) = state;
                        
            % Add saccade time if there is a subsequent saccade
            if dataPoint < length(order),
                distance = abs(order(dataPoint+1) - ep); % distance between the old and new fixation points
                time = time + distance/saccadeVelocity ; % the time it takes to saccade
            end
        end
    end

    function stepThroughAndOutput(criticalPoints)
        
        % Time keeper
        time = 0;
        
        % Get the time of the last fixation
        duration = criticalPoints(1,end);
        
        % invariant: time is presnt time
        while time < duration,
            
            % Interpolate the state from at time
            state = interpolateState(criticalPoints, time);
            
            fwrite(fileID, ..., 'float');
             
            % Next sample
            time = time + 1/samplingRate;
        end
        
    end

    function [time ep retinalTargets] = interpolateState(criticalPoints, time)
    end
    
end