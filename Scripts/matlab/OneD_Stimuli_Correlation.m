%
%  OneD_Stimuli_Correlation.m
%  SMI
%
%  Created by Bedeho Mender on 27/01/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function OneD_Stimuli_Correlation(folderName, dimensions)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Setup space and variables
    allShownTargets       = dimensions.allShownTargets;
    eyePositionsRecord    = dimensions.eyePositionsRecord;
    
    nrOfTargets         = length(allShownTargets);
    nrOfEyePositions    = length(eyePositionsRecord);
    dotproducts         = zeros(nrOfTargets, nrOfEyePositions, nrOfTargets, nrOfEyePositions);
    samplesPrLocation   = uint32(ceil(0.300/0.01));
    
    visualPreferences       = -100:1:100;
    eyePositionPreferences  = -30:1:30;
    gaussianSigma           = 6.0;
    sigmoidSlope            = 0.0625;
    
    % Setup figure
    figure;
    hold on;
    
    % Do computation, and dump to stimuli file
    % t1
    for t1=1:nrOfTargets,
        
        disp(['Progress: ' num2str(100*(t1/nrOfTargets)) '%']);
        
        for e1=1:nrOfEyePositions,
        
            % t2
            for t2=1:nrOfTargets,
                for e2=1:nrOfEyePositions,
                    
                    target1 = dimensions.allShownTargets(t1);
                    target2 = dimensions.allShownTargets(t2);
                    
                    eye_pos1 = dimensions.eyePositionsRecord(t1,e1);
                    eye_pos2 = dimensions.eyePositionsRecord(t2,e2);
                    
                    s1_activity = OneD_Stimuli_InputLayer([eye_pos1,target1-eye_pos1], visualPreferences, eyePositionPreferences, gaussianSigma, sigmoidSlope);
                    s2_activity = OneD_Stimuli_InputLayer([eye_pos2,target2-eye_pos2], visualPreferences, eyePositionPreferences, gaussianSigma, sigmoidSlope);

                    % Normalized dot product
                    overlap = dot(s1_activity(:),s2_activity(:)) / (norm(s1_activity(:)) * norm(s2_activity(:)));
                    dotproducts(t1,e1,t2,e2) = overlap;
                    
                    % Add plot to figure
                    plot(abs(eye_pos1 - eye_pos2), overlap, 'o'); 
                    
                end
            end
            
        end
    end
    
    %% Save as stimuli file: needed for later!
    
    % Open file
    filename = [base 'Stimuli/' folderName '-correlation/data.dat'];
    fileID = fopen(filename,'w');

    % Make header
    fwrite(fileID, dimensions.samplingRate, 'ushort');               % Rate of sampling
    fwrite(fileID, dimensions.numberOfSimultanousTargets, 'ushort'); % Number of simultanously visible targets, needed to parse data
    fwrite(fileID, dimensions.visualFieldSize, 'float');
    fwrite(fileID, dimensions.eyePositionFieldSize, 'float');
    
    % Dump to file
    for t1=1:nrOfTargets,
        for e1=1:nrOfEyePositions,
                                
            target1 = dimensions.allShownTargets(t1);
            eye_pos1 = dimensions.eyePositionsRecord(t1,e1);
                    
            outputSample(fileID, eye_pos1, target1, samplesPrLocation);
        end
    end
    
    % Close stimuli file
    fclose(fileID);
    
    %% Save correlation
    startDir = pwd;
    cd([base 'Stimuli/' folderName '-correlation']);

    save('dotproduct.mat', ...
            'dotproducts', ...
            'allShownTargets', ...
            'eyePositionsRecord');
    cd(startDir);
    
    % Make figure pretty
    
    
    % Save figure
    %saveas(fig,[base 'Stimuli/' folderName '-correlation/dotproducts.eps'],'eps');
    
end