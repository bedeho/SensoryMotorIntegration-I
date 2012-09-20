%
%  OneD_DG_Training.m
%  SMI
%
%  Created by Bedeho Mender on 08/02/12.
%  Copyright 2012 OFTNAI. All rights reserved.
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

function Training(prefix,coeff)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Load enviromental paramters
    dimensions = OneD_DG_Dimensions();
    
    n = dimensions.nrOfVisualTargetLocations;
    r = dimensions.numberOfSimultanousObjects;
    
    % Parameters
    seed                        = 17; % classic = 72
    saccadeVelocity             = 400;	% (deg/s), http://www.omlab.org/Personnel/lfd/Jrnl_Arts/033_Sacc_Vel_Chars_Intrinsic_Variability_Fatigue_1979.pdf
    samplingRate                = 1000;	%<=============change to 1000=========================%1000 % (Hz)
    fixationDuration            = 0.500;  % 0.02;	% (s) - fixation period after each saccade
    nrOfEyePositions            = 8;
    
    % Dynamics
    numberOfTargetPresentations = n*2*2.5;%n*3*2
    fixationsPerTargetChange    = coeff;%floor(*nrOfEyePositions); % 2 * < == for simplicity always make this a multiple if it is greater than nrOfEyePositions
    
    if numberOfTargetPresentations < n,
        error('Not enough to presentations see all targets!!');
    elseif numberOfTargetPresentations*fixationsPerTargetChange < n*nrOfEyePositions,
        error('Not enough presentations to see all targets!!');
    end
    
    % Derived
    possibleEyePositions = centerN2(dimensions.eyePositionFieldSize, nrOfEyePositions);
    
    % No multiline concat... damn
    if nargin < 1,
        prefix = '';
    else
        prefix = [prefix '-']
    end
    
    encodePrefix = [prefix 'Tar=' num2str(dimensions.nrOfVisualTargetLocations,'%.2f')];
    encodePrefix = [encodePrefix '-nTP=' num2str(numberOfTargetPresentations,'%.2f')];
    encodePrefix = [encodePrefix '-ftC=' num2str(fixationsPerTargetChange,'%.2f')];
    encodePrefix = [encodePrefix '-Sim=' num2str(dimensions.numberOfSimultanousObjects,'%.2f')];
    encodePrefix = [encodePrefix '-fD=' num2str(fixationDuration,'%.2f') ];
    encodePrefix = [encodePrefix '-nF=' num2str(nrOfEyePositions,'%.2f') ];
    encodePrefix = [encodePrefix '-vpD=' num2str(dimensions.visualPreferenceDistance,'%.2f')];
    encodePrefix = [encodePrefix '-epD=' num2str(dimensions.eyePositionPrefrerenceDistance,'%.2f')];
    encodePrefix = [encodePrefix '-gS=' num2str(dimensions.gaussianSigma,'%.2f')];
    encodePrefix = [encodePrefix '-sS=' num2str(dimensions.sigmoidSlope,'%.2f')];
    encodePrefix = [encodePrefix '-vF=' num2str(dimensions.visualFieldSize,'%.2f')];
    encodePrefix = [encodePrefix '-eF=' num2str(dimensions.eyePositionFieldSize,'%.2f')];
    encodePrefix = [encodePrefix '-sE=' num2str(seed,'%.2f')];
    tSFolderName = [encodePrefix]; %['random-' encodePrefix];
    
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
    rng(seed, 'twister');
    
    % Setup for generating target combinations
    unsampledPerms = combnk(1:n, r);
    fixedPerms = unsampledPerms;
    counter = 1;
    
    % Setup numbers for eye positions
    if fixationsPerTargetChange >= nrOfEyePositions,
        quotient   = floor(fixationsPerTargetChange/nrOfEyePositions);
        remainder  = mod(fixationsPerTargetChange, nrOfEyePositions);
        unshuffled = repmat(1:nrOfEyePositions, 1, quotient);
        randomEyePositions = randperm(nrOfEyePositions);
        unshuffled = [unshuffled randomEyePositions(1:remainder)];
    end
    
    % Iterate target combinations
    while counter <= numberOfTargetPresentations, 
        
        % Get target order
        if ~isempty(unsampledPerms),
            dim = size(unsampledPerms);
            sampleId = randi(dim(1));
            showTargets = unsampledPerms(sampleId,:);
            unsampledPerms(sampleId,:) = []; % Kill this combination
        else
            showTargets = fixedPerms(randi(length(fixedPerms),1,1));
        end
        
        % Output data sequence for each target
        targets = dimensions.targets(showTargets);
        
        % Generate sequence of fixation targets
        %eyePositionOrder = randi(nrOfEyePositions,1,fixationsPerTargetChange);

        % shuffle
        if fixationsPerTargetChange >= nrOfEyePositions,
            eyePositionOrder = unshuffled(randperm(length(unshuffled)));
        else
            eyePositionOrder = randi(nrOfEyePositions,1,fixationsPerTargetChange);
        end
        
        % Turn indexes into actual eye positions
        eyePositions = possibleEyePositions(eyePositionOrder);

        % Generate the cirtical points
        criticalPoints = generateCriticalPoints(eyePositions);

        % Step through at given frequency and dump to file
        stepThroughAndOutput(criticalPoints);
        
        % Transform flag
        fwrite(fileID, NaN('single'), 'float');
        
        counter = counter + 1;
        
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
    figure;
    hold on;
    
    % Generate complementary testing data
    OneD_DG_Test(tSFolderName, samplingRate, fixationDuration, dimensions, possibleEyePositions);
    
    % Generate correlation data
    OneD_DG_Correlation([tSFolderName '-stdTest']);
    
    % Visualize
    OneD_Overlay([tSFolderName '-training'],[tSFolderName '-stdTest'])
    
    function points = generateCriticalPoints(order)
        
        %points = (time,eye_position,ret_1,...,ret_n)
        
        % Allocate space
        numberOfDataPoints = 2 * length(order); % start and end of each fixation
        dimensionOfDataPoints = 1 + 1 + r; % time + eye_position + ret_1,...,ret_n
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
            
            plot(state(1),state(2),'ro');hold on;
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