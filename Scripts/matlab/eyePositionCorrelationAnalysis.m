%
%  eyePositionCorrelationAnalysis.m
%  SMI
%
%  Created by Bedeho Mender on 15/04/13.
%  Copyright 2013 OFTNAI. All rights reserved.
%

function eyePositionCorrelationAnalysis


    declareGlobalVars();
    
    global base;

    filename = '/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/prewiredLIPnew/X=1_Y=1/TrainedNetwork/firingRate.dat';
    stimuliName = 'peakedgain-visualfield=200.00-eyepositionfield=60.00-fixations=120.00-targets=1.00-fixduration=0.30-fixationsequence=15.00-seed=72.00-samplingrate=1000.00-stdTest';

    % Load stimuli
    startDir = pwd;
    cd([base 'Stimuli/' stimuliName]);
    C = load('info.mat');
    info = C.info;
    cd(startDir);
    
    targets = info.targets;
    eyePositions = info.eyePositions;
    nrOfEyePositionsInTesting = length(eyePositions);
    
    % Load data
    [dataPrEyePosition, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting);

    % Load analysis
    [pathstr, name, ext] = fileparts(filename);
    x = load([pathstr '/analysisResults.mat']);
    analysisResults = x.analysisResults;
    
    % Iterate neurons
    X=[];
    Y = [];
    for row=1:30,
        for col=1:30,
            
            if analysisResults.headCenteredNess(row,col) >= 0.7,

                for e=1:nrOfEyePositionsInTesting,

                    responses = dataPrEyePosition(e, :, row, col);
                    centerOfMass = dot(responses,targets) / sum(responses);

                    X = [X eyePositions(e)];
                    Y = [Y (analysisResults.RFLocation(row,col) - centerOfMass)];
                end

            end
        end
    end
    
    % Do regression
                p = polyfit(X,Y,1);
            a = p(1);
            b = p(2);
    
    % Plot
    figure;
    plot(X,Y,'*','MarkerSize',10);
    ylim([-30 30])
    xlim([-30 30]);
    pbaspect([60 60 1]); % rows, cols
    
    hold on
    % put in eye position line
    plot([-30 30],[30 -30],'--r'); 
    
    % put in head position line
    plot([-30 30],[0 0],'-g');
    
    % put in regression
    plot([-30 30],[(a*-30+b) (a*30+b)],'-.b');
    
    %% pretty it up
    hYLabel = ylabel('Error (deg)');
    hXLabel = xlabel('Eye-position (deg)');
    hLegend = legend({'Error','Eye-centered','Head-centered','Linear fit'});
    set([hYLabel hXLabel hLegend gca], 'FontSize', 16);

end
    
