%
%  OneD_Parse.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  Purpose: Parse 1d data into object form
%

function [objects, minSequenceLength, objectsFound] = OneD_Parse(buffer)

    % Parse data
    lastObjectEnd = 0;
    objectsFound = 0;
    minSequenceLength = bitmax; % Saves the number of data points per head centered location we will include
    for c = 1:length(buffer),
        
        eyePosition = buffer(c, 1);
        
        if isnan(eyePosition),
            objectsFound = objectsFound + 1;
            objects{objectsFound} = buffer((lastObjectEnd + 1):(c-1), :); % use cell to support varying stream sizes
            
            % Clean up duplicates
            %objects{objectsFound} = unique(objects{objectsFound}, 'rows');
            
            lastObjectEnd = c;
            
            % Check if this is the new shortest sequence
            minSequenceLength = min(minSequenceLength, length(objects{objectsFound}));
        end
    end
end