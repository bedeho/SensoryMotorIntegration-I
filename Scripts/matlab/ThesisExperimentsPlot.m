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
    
     
    %% prewiredPO
    %{
    experiment(1).Name = 'Random';
    experiment(1).Folder = expFolder('prewiredPO/X=1_Y=1/BlankNetwork');
    experiment(2).Name = 'Prewired';
    experiment(2).Folder = expFolder('prewiredPO/X=1_Y=1/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    
    %% peakedgain
    %{
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('peakedgain/S=0.80_/BlankNetwork');
    experiment(2).Name = '5 Epochs';
    experiment(2).Folder = expFolder('peakedgain/S=0.80_/TrainedNetwork_e5'); 
    experiment(3).Name = '20 Epochs';
    experiment(3).Folder = expFolder('peakedgain/S=0.80_/TrainedNetwork_e20'); 
    FaceColors = {[1,0,0]; [0.5,0,0.5]; [0,0,1]};
    %}
    
    %% learningrate
    %{
    experiment(1).Name = 'Random';
    experiment(1).Folder = expFolder('learningrate/L=9.00000_/TrainedNetwork');
    FaceColors = {[1,0,0]};
    %}
    
    %% sigma_19_failed
    %{
    experiment(1).Name = 'sigma_19_failed';
    experiment(1).Folder = expFolder('sigma_19_failed/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0500_eS=0.0_/TrainedNetwork');
    FaceColors = {[1,0,0]};
    %}
    
    %% nonlinear_activation_5
    %{
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('nonlinear_activation_5/L=0.05000_S=0.90_sS=00000050.0_sT=0.02_gIC=0.0500_eS=0.0_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('nonlinear_activation_5/L=0.05000_S=0.90_sS=00000050.0_sT=0.02_gIC=0.0500_eS=0.0_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}

    %% decoupled_gainencoding
    %{
    experiment(1).Name = 'decoupled_gainencoding';
    experiment(1).Folder = expFolder('decoupled_gainencoding/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0500_eS=0.0_/TrainedNetwork');
    FaceColors = {[1,0,0]};
    %}
    
    %% multitargettraining_retune
    %{
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('multitargettraining_retune/S=0.80_sS=00000015.0_sT=0.15_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('multitargettraining_retune/S=0.80_sS=00000015.0_sT=0.15_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
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
    
    function folder = expFolder(name)
        folder = [base 'Experiments/' name];
    end

end
