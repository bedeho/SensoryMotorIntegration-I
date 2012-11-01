%
%  Stimuli.m
%  SMI
%
%  Created by Bedeho Mender on 05/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.''
%
%  Purpose: Generates the simplest possible 1d dynamical data
%  
%           Works by first generating a sequence of system
%           states at each non-smooth point in the dynamics
%           of the linear system, i.e. start and end of every 
%           saccade. These points ARE NOT temporally quidistant
%           because fixations last longer than saccades.
%           Than this piecewise linear sequence is stepped through
%           at fixed temporal intervals and the system state is
%           linearly interpolated and saved at each point to file.
%

function Stimuli(prefix)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Load enviromental paramters
    dimensions = OneD_DG_Dimensions();
    
    % Parameters
    seed                        = 70;      % classic = 72
    saccadeVelocity             = 400;      % (deg/s), http://www.omlab.org/Personnel/lfd/Jrnl_Arts/033_Sacc_Vel_Chars_Intrinsic_Variability_Fatigue_1979.pdf
    samplingRate                = 100;      % <=============change to 1000=========================%1000 % (Hz)
    fixationDuration            = 0.200;    % 0.02;	% (s) - fixation period after each saccade
    fixationSequenceLength      = 30;
    
    k = 4;
    numberOfFixations           = fixationSequenceLength * k;%7*50;
    
    % Deduced
    scaleDown = 1/3;% 1/2;
    visualRange = dimensions.visualFieldSize*scaleDown;
    eyePositionRange = dimensions.visualFieldSize/2 - visualRange/2;
    
    % Check 
    if mod(numberOfFixations, fixationSequenceLength) ~= 0,
        error('The number of fixations is not divisible by fixation sequences');
    else
        numberOfSequences = numberOfFixations / fixationSequenceLength;
    end
    
    % No multiline concat... damn
    if nargin < 1,
        prefix = '';
    else
        prefix = [prefix '-']
    end
    
    % Filename
    encodePrefix = [prefix 'Tar=0.00'];
    encodePrefix = [encodePrefix '-nTP=0.00'];
    encodePrefix = [encodePrefix '-nOF=' num2str(numberOfFixations,'%.2f')]; 
    encodePrefix = [encodePrefix '-Sim=' num2str(dimensions.numberOfSimultanousObjects,'%.2f')];
    encodePrefix = [encodePrefix '-fD='  num2str(fixationDuration,'%.2f') ];
    encodePrefix = [encodePrefix '-fSL=' num2str(fixationSequenceLength,'%.2f') ];
    
    encodePrefix = [encodePrefix '-vpD=' num2str(dimensions.visualPreferenceDistance,'%.2f')];
    encodePrefix = [encodePrefix '-epD=' num2str(dimensions.eyePositionPrefrerenceDistance,'%.2f')];
    encodePrefix = [encodePrefix '-gS='  num2str(dimensions.gaussianSigma,'%.2f')];
    encodePrefix = [encodePrefix '-sS='  num2str(dimensions.sigmoidSlope,'%.2f')];
    encodePrefix = [encodePrefix '-vF='  num2str(dimensions.visualFieldSize,'%.2f')];
    encodePrefix = [encodePrefix '-eF='  num2str(dimensions.eyePositionFieldSize,'%.2f')];
    encodePrefix = [encodePrefix '-sE='  num2str(seed,'%.2f')];
    encodePrefix = [encodePrefix '-sR='  num2str(samplingRate,'%.2f')];
    tSFolderName = [encodePrefix];
    
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
    
    % Set seed
    rng(seed, 'twister');
    
    % SYSTEMATIC
    potentialTargets = fliplr(centerN2(visualRange, k));
    unsampledPerms = combnk(1:length(potentialTargets), dimensions.numberOfSimultanousObjects);
    
    
    %leftMostTargetSeen = inf;
    %rightMostTargetSeen = -inf;
    maxDev = 0;
    
    % Perform fixation sequences
    for i=1:numberOfSequences,
        
        % Produce targets
         
        %% UNIFORM
        %targets = visualRange*(rand(1,dimensions.numberOfSimultanousObjects) - 0.5);
        
        %% GAUSSIAN (fixed mean)
        %targets = (visualRange+1)*ones(1,dimensions.numberOfSimultanousObjects);
        %while any(abs(targets) > visualTargetEccentricity/2),
        %    targets = normrnd(0,visualTargetEccentricity/6);
        %end
        
        %% SYSTEMATIC
        dim = size(unsampledPerms);
        sampleId = randi(dim(1));
        showTargets = unsampledPerms(sampleId,:);
        unsampledPerms(sampleId,:) = []; % Kill this combination
        targets = potentialTargets(showTargets); % Output data sequence for each target
        
        %% Update extremes
        %leftMostTargetSeen = min(leftMostTargetSeen,targets);
        %rightMostTargetSeen = max(rightMostTargetSeen,targets);
        maxDev = max(maxDev,abs(targets));
        
        % Produce fixation order
        eyePositions = eyePositionRange*(rand(1,fixationSequenceLength) - 0.5);

        % Generate the cirtical points
        criticalPoints = generateCriticalPoints(eyePositions);

        % Step through at given frequency and dump to file
        stepThroughAndOutput(criticalPoints);
        
        % Transform flag
        fwrite(fileID, NaN('single'), 'float');
        
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
    save('dimensions.mat','dimensions','seed');
    
    cd(startDir);
    
    % Start plotting
    %figure;
    %hold on;
    
    % Generate complementary testing data
    if length(potentialTargets) > 1,
        buffer = abs(potentialTargets(2) - potentialTargets(1))/2
    else
        buffer = 20;
    end
    
    maxDev
    
    Stimuli_Testing(tSFolderName, samplingRate, fixationDuration, dimensions, eyePositionRange, 2*(maxDev + buffer)); % visualRange
    
    % Generate correlation data
    if samplingRate == 10,
        OneD_DG_Correlation([tSFolderName '-stdTest']);
    end
    
    % Visualize
    OneD_Overlay([tSFolderName '-training'],[tSFolderName '-stdTest'])
    
    function points = generateCriticalPoints(order)
        
        %points = (time,eye_position,ret_1,...,ret_n)
        
        % Allocate space
        numberOfDataPoints = 2 * length(order); % start and end of each fixation
        dimensionOfDataPoints = 1 + 1 + dimensions.numberOfSimultanousObjects; % time + eye_position + ret_1,...,ret_n
        points = zeros(dimensionOfDataPoints, numberOfDataPoints);
        
        % Generate
        time = 0;
        
        % Start targets
        %targets = dimensions.targets(randperm(n, r));
        
        % invariant: time is of next point in time
        for dataPoint = 1:length(order),
            
            % Eye position
            ep = order(dataPoint);
            
            % When a sufficient number of fixations have been performed,
            % targets are updated
            %if mod(dataPoint,fixationsPerTargetChange) == 0
            %    
            %    showTargets = randperm(n, r);
            %    targets = dimensions.targets(showTargets);
            %end
            
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
                        
            % Add saccade time if there is a subsequent saccade,
            % which is the case for all but the last iteration
            if dataPoint < length(order),
                % later realized: we dont need to test this!
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