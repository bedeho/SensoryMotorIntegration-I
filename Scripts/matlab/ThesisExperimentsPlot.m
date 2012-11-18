%
%  ThesisExperimentsPlot.m
%  SMI
%
%  Created by Bedeho Mender on 06/11/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function ThesisExperimentsPlot()

    declareGlobalVars();

    global base;
    %global THESIS_FIGURE_PATH;
    
    %save_filename = 'prewiredPO';

    % Save all experiments to include 
    
    %{ 
    %% prewiredPO
    experiment(1).Name = 'Prewired';
    experiment(1).Folder = expFolder('prewiredPO/X=1_Y=1/TrainedNetwork');
    experiment(2).Name = 'Random';
    experiment(2).Folder = expFolder('prewiredPO/X=1_Y=1/BlankNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% peakedgain
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('peakedgain/S=0.80_/BlankNetwork');
    experiment(2).Name = '5 Epochs';
    experiment(2).Folder = expFolder('peakedgain/S=0.80_/TrainedNetwork_e5'); 
    experiment(3).Name = '20 Epochs';
    experiment(3).Folder = expFolder('peakedgain/S=0.80_/TrainedNetwork_e20'); 
    FaceColors = {[1,0,0]; [0.5,0,0.5]; [0,0,1]};
    
    %% Dont need to touch anything below here.
    numExperiments = length(experiment);
    
    % Allocate buffer space
    RFLocation  = cell(1,numExperiments);
    headCenteredNess  = cell(1,numExperiments);
    RFSize = cell(1,numExperiments);
    Legends = cell(1,numExperiments);
    
    % Iterate experiments and plot
    for e = 1:numExperiments,

        % Load analysis file for experiments
        data = load([experiment(e).Folder '/analysisResults.mat']);
        
        % Project out data
        RFLocation{e} = data.analysisResults.RFLocation_Linear_Clean;
        headCenteredNess{e} = data.analysisResults.headCenteredNess_Linear_Clean;
        RFSize{e} = data.analysisResults.RFSize_Linear_Clean;
        
        % Check that we have non-empty dataset
        if(isempty(headCenteredNess{e})),
            error(['Empty data set found' experiment(e).Name]);
        end
        
        % Populate legend cell
        Legends{e} = experiment(e).Name;
        
        % Output key numbers
        disp(['Experiment ' experiment(e).Name ':']);
        disp(['Mean RF-Location: ' num2str(mean(RFLocation{e}))]);
        disp(['Mean Head-centeredness: ' num2str(mean(headCenteredNess{e}))]);
        disp(['Mean RFSize: ' num2str(mean(RFSize{e}))]);
        
        disp(['Fraction discarded due to DISCONTINOUS: ' num2str(data.analysisResults.fractionDiscarded)]);
        disp(['Fraction discarded due to EDGE: ' num2str(data.analysisResults.fractionDiscarded_Edge)]);
        disp(['Fraction discarded due to MULTIPEAK: ' num2str(data.analysisResults.fractionDiscarded_MultiPeak)]);
        disp(['Entropy (> 0.7): ' num2str(data.analysisResults.uniformityOfVeryHeadCentered)]);
        disp('***');
    end
    
    scatterPlotWithMarginalHistograms(RFLocation, headCenteredNess, 'XTitle', 'Receptive Field Location (deg)', 'YTitle', 'Head-Centeredness', 'Legends', Legends,'YLabelOffset', 3, 'FaceColors', FaceColors);
    scatterPlotWithMarginalHistograms(RFSize, headCenteredNess, 'XTitle', 'Receptive Field Size (deg)', 'YTitle', 'Head-Centeredness', 'Legends', Legends ,'YLabelOffset', 1, 'FaceColors', FaceColors);
    
    % SAVE
    %{
    chap = 'chap-2';
    fname = [THESIS_FIGURE_PATH chap '/' save_filename '_retinalconfusion.eps'];
    set(gcf,'renderer','painters');
    print(f,'-depsc2','-painters',fname);
    %}
    
    %}

    function folder = expFolder(name)
        folder = [base 'Experiments/' name];
    end

end
