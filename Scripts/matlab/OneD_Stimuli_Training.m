%
%  OneD_Training.m
%  SMI
%
%  Created by Bedeho Mender on 05/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.''
%
%  Purpose: Generates 1d dynamical data
%  
%           Works by first generating a sequence of system
%           states at each non-smooth point in the dynamics
%           of the linear system, i.e. start and end of every 
%           saccade. These points ARE NOT temporally equidistant
%           because fixations last longer than saccades.
%           Than this piecewise linear sequence is stepped through
%           at fixed temporal intervals and the system state is
%           linearly interpolated and saved at each point to file.
%

function OneD_Stimuli_Training(prefix, fixationSigma)%, numberOfNonSpesificFixations)%, dist) %), headPositions) % fixationSequenceLength, ) 

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Technical
    seed                                = 72; % classic = 72
    samplingRate                        = 100; % (Hz)
    
    % Environment
    numberOfSimultanousTargets          = 1; % classic = 1
    q                                   = 0.7; % targetRangeProportionOfVisualField
    visualFieldSize                     = 200; % Entire visual field (rougly 100 per eye), (deg)
    eyePositionFieldSize                = (1-q)*visualFieldSize; % (1-q)*visualFieldSize OR equivalently (visualFieldSize/2 - targetVisualRange/2)
    targetVisualRange                   = 0.9*visualFieldSize * q;
    targetEyePositionRange              = 0.8*eyePositionFieldSize;
    
    % Agent Movement
    saccadeVelocity                     = 400; % (deg/s), http://www.omlab.org/Personnel/lfd/Jrnl_Arts/033_Sacc_Vel_Chars_Intrinsic_Variability_Fatigue_1979.pdf
    fixationDuration                    = 0.3; % (s) - fixation period after each saccade
    
    % Agent in Training
    
    %% CLASSIC/Varying #head positions
    headPositions                       = 8; % classic = 8
    fixationSequenceLength              = 15; % classic = 15
    numberOfFixations                   = headPositions*fixationSequenceLength; % classic = ;
    
    % Variations
    numberOfNonSpesificFixations        = 0;
    %fixationSigma                       = 0.100; % (s)
    
    %% Varying fixation sequence length
    %{
    headPositions                       = 8;
    numberOfFixations                   = 200;
    %}
    
    % Agent in Testing
    nrOfTestingEyePositions             = 4;
    nrOfRetinalTestingPositions         = 80;
    
    % Deduce number of sequences
    %numberOfSequences                   = ceil(numberOfFixations / fixationSequenceLength);
    
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
                         '-targets='            num2str(numberOfSimultanousTargets,'%.2f') ...
                         '-fixduration='        num2str(fixationDuration,'%.2f') ...
                         '-fixationsequence='   num2str(fixationSequenceLength,'%.2f') ...
                         '-seed='               num2str(seed,'%.2f') ...
                         '-samplingrate='       num2str(samplingRate,'%.2f') ...
                         '-numNonSpesFix='      num2str(numberOfNonSpesificFixations, '%.2f') ...
                         '-fixationSigma='      num2str(fixationSigma, '%.2f')];
    
    tSPath = [base 'Stimuli/' folderName '-training'];
    %testPath = [base 'Stimuli/' folderName '-stdTest'];
    %testPath = = [base 'Stimuli/' folderName '-training'];
    
    
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
    
    % SYSTEMATIC
    potentialTargets = fliplr(centerN2(targetVisualRange, headPositions));
    unsampledPerms = combnk(1:length(potentialTargets), numberOfSimultanousTargets);
    
    % Helpful variables
    maxDev = 0;
    allShownTargets = [];
    
    disp('Generating Training Data.');
    
    % For multiple target case
    fixedeyePositions = targetEyePositionRange*(rand(1, fixationSequenceLength) - 0.5);
    
    % Perform fixation sequences
    i = 1;
    numInitialPerms = length(unsampledPerms);
    while ~isempty(unsampledPerms),
        
        % Produce targets
         
        %% UNIFORM
        %targets = targetVisualRange*(rand(1, numberOfSimultanousTargets) - 0.5);
        
        %% GAUSSIAN (fixed mean)
        %{
        targets = (targetVisualRange+1)*ones(1, numberOfSimultanousTargets);
        while any(abs(targets) > targetVisualRange/2),
            targets = normrnd(0, targetVisualRange/6); % Find better way
            %to set std
        end
        %}
                
        %% SYSTEMATIC
        dim = size(unsampledPerms);
        sampleId = randi(dim(1));
        showTargets = unsampledPerms(sampleId,:);
        unsampledPerms(sampleId,:) = []; % Kill this combination
        targets = potentialTargets(showTargets); % Output data sequence for each target
        
        % Save targets seen
        allShownTargets = [allShownTargets; targets];

        % Update extremes
        maxDev = max(maxDev,abs(targets));
        
        % Produce fixation order
        if numberOfSimultanousTargets > 1
            eyePositions = fixedeyePositions;
        else
            eyePositions = targetEyePositionRange*(rand(1, fixationSequenceLength) - 0.5);
        end
        
        % CLASSIC: Used target is stationary in head-centered space
        SAMEtargetsPerEyePosition = repmat(targets, fixationSequenceLength, 1);
        
        % Generate and output dynamics
        generateDynamicsAndSave(SAMEtargetsPerEyePosition, eyePositions);
        
        %% Non-classic distrations: numberOfNonSpesificFixations
        if numberOfNonSpesificFixations > 0,
            
            eyePositions            = targetEyePositionRange*(rand(1, numberOfNonSpesificFixations) - 0.5);
            targetsPerEyePosition   = targetVisualRange*(rand(numberOfNonSpesificFixations, numberOfSimultanousTargets) - 0.5);
            
            generateDynamicsAndSave(targetsPerEyePosition, eyePositions);
        end
        
        % Status
        disp([num2str(100*(i/numInitialPerms)) '%']);
        
        % Iterator
        i = i + 1;
        
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
         'numberOfSimultanousTargets', ...
         'visualFieldSize', ...
         'eyePositionFieldSize', ...
         'targetVisualRange', ...
         'targetEyePositionRange', ...
         'seed', ...
         'saccadeVelocity', ...
         'samplingRate', ...
         'fixationDuration', ...
         'fixationSequenceLength', ...
         'numberOfFixations', ...
         'allShownTargets');
                      
    cd(startDir);
    
    % Generate complementary testing data
    %{
    if length(potentialTargets) > 1,
        margin = abs(potentialTargets(2) - potentialTargets(1));
    else
        margin = 20;
    end
    %}
    
    margin = 10;
    
    % Testing Parameters
    testingRetinalFieldSize = max(2*(maxDev + 3*margin)); % *buffer
    
    if testingRetinalFieldSize > nrOfRetinalTestingPositions,
        testingTargets = fliplr(centerN2(testingRetinalFieldSize, nrOfRetinalTestingPositions));
    else
        testingTargets = fliplr(centerN2(nrOfRetinalTestingPositions, nrOfRetinalTestingPositions)); 
    end
    
    testingEyePositionFieldSize = targetEyePositionRange*0.8
    disp('TIGHT TESTING>>>>>>>>>>>>>>>>> REMOVE!!!');
    testingEyePositions = centerN2(testingEyePositionFieldSize, nrOfTestingEyePositions);
    
    % Generate testing data
    disp('Generating Single Target Testing Data.');
    OneD_Stimuli_Testing(folderName, samplingRate, fixationDuration, visualFieldSize, eyePositionFieldSize, testingEyePositions, testingTargets);
    
    %{
    % Generate multiple targets testing data
    if nargin > 1,
        disp('Generating Multiple Target Testing Data.');
        OneD_Stimuli_CLASSICMultiTargetTesting(folderName, samplingRate, fixationDuration, visualFieldSize, eyePositionFieldSize, testingEyePositions, testingTargets, 2, dist);
        OneD_Stimuli_NEWMultiTargetTesting(folderName, samplingRate, fixationDuration, visualFieldSize, eyePositionFieldSize, testingEyePositions, testingTargets, 2, dist);
    end
    %}
    
    % Make stimuli figures
    if numberOfSimultanousTargets  == 1,
        
        disp('Making Spatial Plot.');
        OneD_Stimuli_SpatialFigure([folderName '-training'], [folderName '-stdTest']);

        disp('Making Temporal Plot.');
        OneD_Stimuli_MovementDynamicsFigure([folderName '-training']);
    else
        disp('Cannot produce figures for multiple object training');
    end
    
    % Generate correlation data
    if samplingRate == 10,
        %disp('Computing correlation.');
        %OneD_Stimuli_Correlation([folderName '-stdTest']);
    end
    
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
                fixTime = normrnd(fixationDuration, fixationSigma, 1);
            end
            
            time = time + fixTime;
            
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