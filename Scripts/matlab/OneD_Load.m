%
%  OneD_Load.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: load 1d data
%

function [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Load(stimuliName)

    % Import global variables
    declareGlobalVars();
    
    global base; % importing

    filename = [base 'Stimuli/' stimuliName '/data.dat'];

    % Open file
    fileID = fopen(filename);

    % Read header
    samplingRate = fread(fileID, 1, 'ushort');               % Rate of sampling
    numberOfSimultanousObjects = fread(fileID, 1, 'ushort'); % Number of simultanously visible targets, needed to parse data
    visualFieldSize = fread(fileID, 1, 'float');           % Size of visual field
    eyePositionFieldSize = fread(fileID, 1, 'float');
    
    % Read body,
    % we cannot read in one blow because the internal sequence sepeartors
    % are in arbitrary locations, at the very least in real data.
    counter = 0;
    buffer = []; % we could compute a funky and very loose upper bound on size, but it would be odd
    while true,
        
        % Read sample from file
        eyePosition = fread(fileID, 1, 'float');
        
        % Check if we read last sample in file
        if feof(fileID)
            break;
        end
        
        % Consume reset
        if ~isnan(eyePosition),
            
            retinalPositions = fread(fileID, numberOfSimultanousObjects,'float');
            buffer = [buffer; eyePosition retinalPositions'];
        else

            % Reset counter at last object
            buffer = [buffer; nan (nan * ones(1,numberOfSimultanousObjects))];
        end
        
        counter = counter + 1;
    end
    
    fclose(fileID);