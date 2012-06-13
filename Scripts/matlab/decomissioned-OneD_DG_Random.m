%
%  OneD_DG_Random.m
%  SMI
%
%  Created by Bedeho Mender on 08/02/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  Purpose: Generates the simplest possible 1d dynamical data
%

%{
WORKS- BUT NOT NEEDED

function OneD_DG_Random(prefix)

    % Import global variables
    declareGlobalVars();
    
    global base;

    % Load enviromental paramters
    dimensions = OneD_DG_Dimensions();
    
    % Movement parameters
    saccadeVelocity             = 4000000000000000000000;	% (deg/s), http://www.omlab.org/Personnel/lfd/Jrnl_Arts/033_Sacc_Vel_Chars_Intrinsic_Variability_Fatigue_1979.pdf
    samplingRate                = 1000;	% (Hz)
    fixationDuration            = 0.050;  % 0.25;	% (s) - fixation period after each saccade
    saccadeAmplitude            = 10;    % 30= 13 hp(deg) - angular magnitude of each saccade, after which there is a fixation periode

    % Derived
    ticksPrSample = fixationDuration * samplingRate;
    nrOfSubsequentEyeMovements = 1;
    nrOfRandomMovements = 50;
    
    possibleEyePositions = dimensions.leftMostEyePosition:saccadeAmplitude:dimensions.rightMostEyePosition;
    nrOfEyePositions = length(possibleEyePositions);

    % No multiline concat... damn
    if nargin < 1,
        prefix = '';
    else
        prefix = [prefix '-']
    end
    
    encodePrefix = [prefix 'move=' num2str(nrOfRandomMovements) '_' num2str(nrOfSubsequentEyeMovements) '-'];
    encodePrefix = [encodePrefix 'fD=' num2str(fixationDuration,'%.2f') ];
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
    
    % Output data sequence for each target
    for t = dimensions.targets,
        
        % Save at t=0
        %fwrite(fileID, dimensions.leftMostEyePosition, 'float');           % Eye position (HFP)
        %fwrite(fileID, t - dimensions.leftMostEyePosition, 'float');       % Fixation offset of target

        % Output all samples for this target position
        doTimeSteps();
        
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
    OneD_DG_Test(tSFolderName, dimensions.targetBoundary, dimensions.visualFieldSize, dimensions.eyePositionFieldSize);
    OneD_DG_TestOnTrained([tSFolderName '-training']);
    
    % Generate correlation data
    OneD_DG_Correlation([tSFolderName '-testOnTrained']);
    
    % Visualize
    OneD_Overlay([tSFolderName '-training'],[tSFolderName '-testOnTrained'])
    
    function doTimeSteps()

        % Do a random eye movement
        for n = 1:nrOfRandomMovements,
            
            % Pick saccade target
            s = randi(nrOfEyePositions);
            
            % Pick direction
            if randi(2) == 1,
                d = -1; % left
            else
                d = 1;
            end
            
            % Do a number of extra saccades
            for r = 0:nrOfSubsequentEyeMovements,
                
                newPosition = s + d*r;
                
                % Loop around if we need to
                if newPosition > nrOfEyePositions || newPosition < 1
                    ep = possibleEyePositions(1);
                else
                    ep = possibleEyePositions(newPosition);
                end
                                
                % Output 
                sample = [ep (t - ep)];
                
                % Duplicat sample and write out duplicates in column order
                repeatedSample = repmat(sample,1,ticksPrSample);
                fwrite(fileID, repeatedSample, 'float');

            end
        end
    end
    
end
%}