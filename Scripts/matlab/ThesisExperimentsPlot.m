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
    
    %% 8H_13E_FIX1200ms
    %{
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('8H_13E_FIX1200ms/sT=0.40_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('8H_13E_FIX1200ms/sT=0.40_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% 8H_13E_FIX1200ms-w-0.1
    %{
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('8H_13E_FIX1200ms-w-0.1/L=0.90000_S=0.80_sS=00000006.0_sT=0.40_gIC=0.0500_eS=0.0_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('8H_13E_FIX1200ms-w-0.1/L=0.90000_S=0.80_sS=00000006.0_sT=0.40_gIC=0.0500_eS=0.0_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% 8H_13E_FIX1200ms-w-0.1-covariance-TUNE
    %{
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('8H_13E_FIX1200ms-w-0.1-covariance-TUNE/S=0.90_sT=0.10_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('8H_13E_FIX1200ms-w-0.1-covariance-TUNE/S=0.90_sT=0.10_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% singlerandomepeak/sS=00000007.0_sT=0.05_
    %{
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('singlerandomepeak/sS=00000007.0_sT=0.05_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('singlerandomepeak/sS=00000007.0_sT=0.05_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% doublepeak_0.30/L=0.05000_S=0.90_sS=00000004.50_sT=0.10_gIC=0.0500_eS=0.0_
    %{
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('doublepeak_0.30/L=0.05000_S=0.90_sS=00000004.50_sT=0.10_gIC=0.0500_eS=0.0_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('doublepeak_0.30/L=0.05000_S=0.90_sS=00000004.50_sT=0.10_gIC=0.0500_eS=0.0_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% global_slopetuning/sS=00000003.0_
    %{
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('global_slopetuning/sS=00000003.0_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('global_slopetuning/sS=00000003.0_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% planargain/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_
    
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('planargain/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('planargain/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    
    
    %% prewiredLIPnew/X=1_Y=1
    %{
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('prewiredLIPnew/X=1_Y=1/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('prewiredLIPnew/X=1_Y=1/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% prewiredLIPold/X=1_Y=1
    %{
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('prewiredLIPold/X=1_Y=1/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('prewiredLIPold/X=1_Y=1/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% prewiredLIPnew_selforganization/X=1_Y=1
    %{
    experiment(1).Name = 'Hardwired';
    experiment(1).Folder = expFolder('prewiredLIPnew_selforganization/X=1_Y=1/TrainedNetwork_e0');
    experiment(2).Name = '10 Epochs';
    experiment(2).Folder = expFolder('prewiredLIPnew_selforganization/X=1_Y=1/TrainedNetwork_e10');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% prewiredLIPnew_selforganization/X=1_Y=1
    %{
    experiment(1).Name = 'Hardwired';
    experiment(1).Folder = expFolder('prewiredLIPold_selforganization/X=1_Y=1/TrainedNetwork_e0');
    experiment(2).Name = '10 Epochs';
    experiment(2).Folder = expFolder('prewiredLIPold_selforganization/X=1_Y=1/TrainedNetwork_e10');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_
    %{
    experiment(1).Name = 'TrainedNetwork_e1p_1';
    experiment(1).Folder = expFolder('planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork_e1p_1');
    experiment(2).Name = 'TrainedNetwork_e1p_2';
    experiment(2).Folder = expFolder('planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork_e1p_2');
    experiment(3).Name = 'TrainedNetwork_e1p_3';
    experiment(3).Folder = expFolder('planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork_e1p_3');    
    experiment(4).Name = 'TrainedNetwork_e1p_4';
    experiment(4).Folder = expFolder('planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork_e1p_4');
    experiment(5).Name = 'TrainedNetwork_e1p_5';
    experiment(5).Folder = expFolder('planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork_e1p_5');
    experiment(6).Name = 'TrainedNetwork_e1p_6';
    experiment(6).Folder = expFolder('planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork_e1p_6');
    experiment(7).Name = 'TrainedNetwork_e1p_7';
    experiment(7).Folder = expFolder('planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork_e1p_7');
    experiment(8).Name = 'TrainedNetwork_e1p_8';
    experiment(8).Folder = expFolder('planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork_e1p_8');
    FaceColors = {[1,0,0]; [0,0,1]; [1,0,0]; [1,0,0]; [1,0,0]; [1,0,0]; [1,0,0]; [1,0,0];};
    %}
    
    %% Dont need to touch anything below here.
    numExperiments = length(experiment);
    
    % Allocate buffer space
    RFLocation  = cell(1,numExperiments);
    headCenteredNess  = cell(1,numExperiments);
    eyeCenteredNess  = cell(1,numExperiments);
    RFSize = cell(1,numExperiments);
    Legends = cell(1,numExperiments);
    
    %IndexTrack = [];
    
    % Iterate experiments and plot
    for e = 1:numExperiments,

        % Load analysis file for experiments
        data = load([experiment(e).Folder '/analysisResults.mat']);
        
        % Project out data
        RFLocation{e} = data.analysisResults.RFLocation_Linear_Clean;
        headCenteredNess{e} = data.analysisResults.headCenteredNess_Linear_Clean;
        
        x = data.analysisResults;
        if(isfield(x,'eyeCenteredNess_Linear_Clean')),
            eyeCenteredNess{e} = data.analysisResults.eyeCenteredNess_Linear_Clean;
        end
        
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
        
        if(isfield(x,'eyeCenteredNess_Linear_Clean')),
            disp(['Mean Eye-centeredness: ' num2str(mean(eyeCenteredNess{e}))]);
            
            %index = x.headCenteredNess_Linear; %x.eyeCenteredNess_Linear %(x.eyeCenteredNess_Linear - x.headCenteredNess_Linear)./(x.eyeCenteredNess_Linear + x.headCenteredNess_Linear);
            %IndexTrack = [IndexTrack; index'];
            
        end
        
        disp(['Mean RFSize: ' num2str(mean(RFSize{e}))]);
        disp(['Fraction >=0.7: ' num2str(nnz(headCenteredNess{e} >= 0.7)/numel(headCenteredNess{e}))]);
        
        disp(['Fraction discarded due to DISCONTINOUS: ' num2str(data.analysisResults.fractionDiscarded)]);
        disp(['Fraction discarded due to EDGE: ' num2str(data.analysisResults.fractionDiscarded_Edge)]);
        disp(['Fraction discarded due to MULTIPEAK: ' num2str(data.analysisResults.fractionDiscarded_MultiPeak)]);
        disp(['Entropy (> 0.7): ' num2str(data.analysisResults.uniformityOfVeryHeadCentered)]);
        disp('***');
    end
    
    scatterPlotWithMarginalHistograms(RFLocation, headCenteredNess, 'XTitle', 'Receptive Field Location (deg)', 'YTitle', 'Head-Centeredness', 'Legends', Legends,'YLabelOffset', 3, 'FaceColors', FaceColors);
    scatterPlotWithMarginalHistograms(RFSize, headCenteredNess, 'XTitle', 'Receptive Field Size (deg)', 'YTitle', 'Head-Centeredness', 'Legends', Legends ,'YLabelOffset', 1, 'FaceColors', FaceColors);
    
    if(isfield(x,'eyeCenteredNess_Linear_Clean')),
        [maxPlot, miniPlot yProjectionAxis, scatterAxis, xProjectionAxis, XLim, YLim] = scatterPlotWithMarginalHistograms(eyeCenteredNess, headCenteredNess, 'XTitle', 'Eye-Centeredness', 'YTitle', 'Head-Centeredness', 'Legends', Legends , 'FaceColors', FaceColors, 'XLim', [0 1], 'YLim', [0 1]);
        axes(scatterAxis);
        %ylim([-0 1])
        %xlim([0 1]);
        set(gca,'XTick', 0:0.2:1);
        hold on
        plot([0 1],[0 1],'--k');
        
        %figure;
        %plot(IndexTrack);
    end
    
    function folder = expFolder(name)
        folder = [base 'Experiments/' name];
    end

end
