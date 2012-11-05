%
%  OneD_Correlation.m
%  SMI
%
%  Created by Bedeho Mender on 27/01/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function OneD_Correlation(stimuliName)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Generate correlation data
    dimensions = OneD_DG_Dimensions();
    
    % Allocate space, is reused
    tempspacetemp = zeros(2, dimensions.nrOfVisualPreferences, dimensions.nrOfEyePositionPrefrerence);

    [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, bufferTesting] = OneD_Load(stimuliName);
    [objects, minSequenceLength, objectsFound] = OneD_Parse(bufferTesting);
    
    dotproduct = zeros(objectsFound, objectsFound);
    
    for o1 = 1:objectsFound,
        
        o1
        for o2 = 1:objectsFound,
            
            tmp1 = objects{o1};
            tmp2 = objects{o2};
            
            % We just pick first row, as all rows should be identical!!
            pattern1 = tmp1(1,:);
            pattern2 = tmp2(1,:);
            
            v1 = OneD_DG_InputLayer(dimensions, pattern1);
            v2 = OneD_DG_InputLayer(dimensions, pattern2);
            
            % Normalized dot product
            dotproduct(o1,o2) = dot(v1(:),v2(:)) / (norm(v1(:)) * norm(v2(:)));

        end
    end
    
    fig = figure();
    imagesc(dotproduct);
    
    % Save correlation
    startDir = pwd;
    cd([base 'Stimuli/' stimuliName]);
    save dotproduct; 
    cd(startDir);
    
     % Save figure
    saveas(fig,[base 'Stimuli/' stimuliName '/correlation.png'],'png');
    
end