%
%  OneD_Stimuli_Training_FLAT.m
%  SMI
%
%  Created by Bedeho Mender on 29/08/13.
%  Copyright 2013 OFTNAI. All rights reserved.''
%
%  Purpose: Generates 1d dynamical data which is random
%  
%

function OneD_Stimuli_Training_FLAT(prefix)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Technical
    seed                                = 72; % classic = 72
    samplingRate                        = 1000; % (Hz)
    
    % Environment
    numberOfSimultanousTargets          = 1; % classic = 1
    q                                   = 0.7; % targetRangeProportionOfVisualField
    visualFieldSize                     = 200; % Entire visual field (rougly 100 per eye), (deg)
    eyePositionFieldSize                = (1-q)*visualFieldSize; % classic=60, quivalently (visualFieldSize/2 - targetVisualRange/2)
    targetVisualRange                   = 0.9*visualFieldSize*q;
    targetEyePositionRange              = 0.8*eyePositionFieldSize;% classic=48
    testingEyePositionFieldSize         = targetEyePositionRange;
    
    % Agent Movement
    saccadeVelocity                     = 400; % (deg/s), http://www.omlab.org/Personnel/lfd/Jrnl_Arts/033_Sacc_Vel_Chars_Intrinsic_Variability_Fatigue_1979.pdf
    trainingFixationDuration            = 0.3; % 0.3, is used as mean if fixationSigma >0, (s) - fixation period after each saccade
    testingFixationDuration             = 0.3; % dont change
    
    numberOfFixations = 1; % per target
    
    % Agent in Training
    numberDataPoints                   = 200;
    fixationSigma                      = 0;
    
    % Agent in Testing
    nrOfTestingEyePositions             = 4;
    nrOfRetinalTestingPositions         = 80;
    
    % Filename
    if nargin < 1,
        prefix = '';
    else
        prefix = [prefix '-'];
    end
    
    folderName = [prefix ...
                         'visualfield='         num2str(visualFieldSize,'%.2f') ...
                         '-eyepositionfield='   num2str(eyePositionFieldSize,'%.2f') ...
                         '-fixations='          num2str(numberOfFixations,'%.2f') ...
                         '-seed='               num2str(seed,'%.2f') ...
                         '-samplingrate='       num2str(samplingRate,'%.2f')];
    
    tSPath = [base 'Stimuli/' folderName '-training'];    
    
    % Make folder
    if ~isdir(tSPath),
        mkdir(tSPath);
    end
    
    % Open file
    filename = [tSPath '/data.dat'];
    fileID = fopen(filename,'w');

    % Make header
    fwrite(fileID, samplingRate, 'ushort');               % Rate of sampling
    fwrite(fileID, numberOfSimultanousTargets, 'ushort'); % Number of simultanously visible targets, needed to parse data
    fwrite(fileID, visualFieldSize, 'float');
    fwrite(fileID, eyePositionFieldSize, 'float');
    
    % Set seed
    rng(seed, 'twister');
    
    % Generate training data
    disp('Generating Training Data.');
    maxDev = 0;
    
    allShownTargets = [];
    eyePositionsRecord = [];
    fixations = [];
    
    % Perform fixation sequences
    for i=1:numberDataPoints,
        
        i
        
        % Produce targets
        target = targetVisualRange*(rand(1, 1) - 0.5); % Output data sequence for each target
        
        % Update extremes
        maxDev = max(maxDev,abs(target));
        
        % Produce fixation
        eyePositions = targetEyePositionRange*(rand(1, 1) - 0.5);
        
        % Generate and save trace
        generateDynamicsAndSave(target, eyePositions);
        
        % Save record
        allShownTargets = [allShownTargets; target] % Save in record
        eyePositionsRecord = [eyePositionsRecord; eyePositions]; % Save in record

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
    save('dimensions.mat', ...
         'visualFieldSize', ...
         'eyePositionFieldSize', ...
         'targetVisualRange', ...
         'targetEyePositionRange', ...
         'seed', ...
         'saccadeVelocity', ...
         'samplingRate', ...
         'trainingFixationDuration', ...
         'numberOfFixations', ...
         'allShownTargets', ...
         'eyePositionsRecord');
     
    % keep it around, may be of use
    dimensions = load('dimensions.mat');
                      
    cd(startDir);
    
    margin = 10;
    
    % Testing Parameters
    testingRetinalFieldSize = max(2*(maxDev + 3*margin));
    
    if testingRetinalFieldSize > nrOfRetinalTestingPositions,
        testingTargets = fliplr(centerN2(testingRetinalFieldSize, nrOfRetinalTestingPositions));
    else
        testingTargets = fliplr(centerN2(nrOfRetinalTestingPositions, nrOfRetinalTestingPositions)); 
    end
    
    testingEyePositions = centerN2(testingEyePositionFieldSize, nrOfTestingEyePositions);
    
    % Generate testing data
    disp('Generating Single Target Testing Data.');
    OneD_Stimuli_Testing(folderName, samplingRate, testingFixationDuration, visualFieldSize, eyePositionFieldSize, testingEyePositions, testingTargets);
        
    % Make stimuli figures
    disp('Making Spatial Plot.');
    OneD_Stimuli_SpatialFigure([folderName '-training'], [folderName '-stdTest'], eyePositionsRecord, allShownTargets);

    disp('Making Temporal Plot.');
    OneD_Stimuli_MovementDynamicsFigure([folderName '-training']);
    
    function generateDynamicsAndSave(targetsPerEyePosition, eyePositions)
                            
        % Generate the cirtical points
        criticalPoints = generateCriticalPoints(targetsPerEyePosition, eyePositions);

        % Step through at given frequency and dump to file
        stepThroughAndOutput(criticalPoints);

        % Transform flag
        fwrite(fileID, NaN('single'), 'float');
        
    end

    function points = generateCriticalPoints(targetsPerEyePosition, eyePositions)
        
        %
        % eyePositions = vector of M eye positions for fixation
        % 
        % targetsPerEyePosition = MxN matrix of target locations, where the
        % location of the N targets at fixation nr i is
        % targetsPerEyePosition(i,:)
        %
        
        % points = (time,eye_position,ret_1, ... ,ret_n)
        
        % Allocate space
        numberOfDataPoints = 2 * length(eyePositions); % start and end of each fixation
        dimensionOfDataPoints = 1 + 1 + numberOfSimultanousTargets; % time + eye_position + ret_1,...,ret_n
        points = zeros(dimensionOfDataPoints, numberOfDataPoints);
        
        % Generate
        time = 0;
        
        % Start targets
        %targets = dimensions.targets(randperm(n, r));
        
        % invariant: time is of next point in time
        for dataPoint = 1:length(eyePositions),
            
            % Eye position
            ep = eyePositions(dataPoint);
            
            % When a sufficient number of fixations have been performed,
            % targets are updated
            %if mod(dataPoint,fixationsPerTargetChange) == 0
            %    
            %    showTargets = randperm(n, r);
            %    targets = dimensions.targets(showTargets);
            %end
            
            % Retinal target locations
            retinalTargets = targetsPerEyePosition(dataPoint,:) - ep;
            
            % Update and save state of fixation START
            state = [time ep retinalTargets];
            points(:,dataPoint*2-1) = state;
            
            % Add some time for end of fixation point
            fixTime = 0;
            while fixTime <= 0,
                fixTime = normrnd(trainingFixationDuration, fixationSigma, 1);
            end
            
            time = time + fixTime;
            
            % Save fixation
            fixations = [fixations; fixTime ep retinalTargets]; % duration, eye, ret_1, ..., ret_n
            
            % Update and save state of fixation END
            state = [time ep retinalTargets];
            points(:,dataPoint*2) = state;
                        
            % Add saccade time if there is a subsequent saccade,
            % which is the case for all but the last iteration
            if dataPoint < length(eyePositions),
                % later realized: we dont need to test this!
                distance = abs(eyePositions(dataPoint+1) - ep); % distance between the old and new fixation points
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
            
            % Remove time
            state = state(2:end)';
            
            fwrite(fileID, state, 'float');
             
            % Next sample
            time = time + 1/samplingRate;
            
            % DEBUG
            %plot(state(1),state(2),'ro');hold on;
            %debugCounter = debugCounter + 1;
        end
        
    end

    % Very inefficient, but it works,
    function state = interpolateState(criticalPoints, time)
        
        c = 1;
        
        % Find position point c immediatly past the desired time,
        % the means that point c-1 will be some time prior to desired
        % time by definition.
        while criticalPoints(1,c) < time,
            c = c + 1;
        end
        
        % If the very first data point is desired, then
        % time==0, and we can just serve up that point
        % without any interpolation
        if c == 1,
            state = criticalPoints(:,1);
        else
            
            % Get some time points
            before = criticalPoints(:,c-1);
            after = criticalPoints(:,c);
            %overflow = after(1) - time;
            overflow = time - before(1);
            
            % Get change rate
            delta = after - before;
            dt = delta(1);
            rate = delta/dt;
            
            % Do linear interpolation
            state = before + overflow*rate;
        end
    end
    
end