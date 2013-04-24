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
    dotproducts_sigmoid = zeros(nrOfTargets, nrOfEyePositions, nrOfTargets, nrOfEyePositions);
    dotproducts_gauss   = zeros(nrOfTargets, nrOfEyePositions, nrOfTargets, nrOfEyePositions);
    samplesPrLocation   = uint32(ceil(0.300/0.01));
    
    visualPreferences       = -100:1:100;
    eyePositionPreferences  = -30:1:30;
    gaussianSigma           = 6.0;
    sigmoidSlope            = 0.0625;
    
    % Setup figure
    fig = figure;
    hold on;
    
    % Do computation, and dump to stimuli file
    % t1
    for t1=1:nrOfTargets,
        
        disp(['Progress: ' num2str(100*(t1/nrOfTargets)) '%']);
        
        for e1=1:nrOfEyePositions,
        
            
            % t2
            for t2=1:nrOfTargets,
                
                if(t1==t2),
                    continue;
                end
                
                
                for e2=1:nrOfEyePositions,
                    
                    target1 = dimensions.allShownTargets(t1);
                    target2 = dimensions.allShownTargets(t2);
                    
                    eye_pos1 = dimensions.eyePositionsRecord(t1,e1);
                    eye_pos2 = dimensions.eyePositionsRecord(t2,e2);
                    
                    ret_1 = target1-eye_pos1;
                    ret_2 = target2-eye_pos2;
                    
                    % SIGMOID
                    s1_activity = OneD_Stimuli_InputLayer([eye_pos1,ret_1], true, visualPreferences, eyePositionPreferences, gaussianSigma, sigmoidSlope);
                    s2_activity = OneD_Stimuli_InputLayer([eye_pos2,ret_2], true, visualPreferences, eyePositionPreferences, gaussianSigma, sigmoidSlope);
                    overlap = dot(s1_activity(:),s2_activity(:)) / (norm(s1_activity(:)) * norm(s2_activity(:)));
                    dotproducts_sigmoid(t1,e1,t2,e2) = overlap;
                    plot(abs(ret_1 - ret_2), overlap, 'ob'); % Add plot to figure
                    
                    % GAUSS
                    s1_activity = OneD_Stimuli_InputLayer([eye_pos1,ret_1], false, visualPreferences, eyePositionPreferences, gaussianSigma, sigmoidSlope);
                    s2_activity = OneD_Stimuli_InputLayer([eye_pos2,ret_2], false, visualPreferences, eyePositionPreferences, gaussianSigma, sigmoidSlope);
                    overlap = dot(s1_activity(:),s2_activity(:)) / (norm(s1_activity(:)) * norm(s2_activity(:)));
                    dotproducts_gauss(t1,e1,t2,e2) = overlap;
                    plot(abs(ret_1 - ret_2), overlap, 'or'); % Add plot to figure

                end
            end
            
        end
    end
    
    %% Save as stimuli file: needed for later!
    
    % Make folder
    tSPath = [base 'Stimuli/' folderName '-correlation'];
    if ~isdir(tSPath),
        mkdir(tSPath);
    end
    
    % Open file
    filename = [tSPath '/data.dat'];
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
    
    % Save correlation
    startDir = pwd;
    cd([base 'Stimuli/' folderName '-correlation']);

    save('dotproduct.mat', ...
            'dotproducts_sigmoid', ...
            'dotproducts_gauss', ...
            'allShownTargets', ...
            'eyePositionsRecord');
    cd(startDir);
    
    % Make figure pretty
    hYLabel = xlabel('Retinal error (deg)');
    hXLabel = ylabel('Input pattern similarity');
    set([hYLabel hXLabel], 'FontSize', 16);
    set(gca, 'FontSize', 14);
    axis tight 
    box on
    legend('Planar','Peaked');
    
    % Save figure
    saveas(fig,[base 'Stimuli/' folderName '-correlation/dotproducts.eps'],'eps');
    
end